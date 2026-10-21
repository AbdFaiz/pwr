<?php

namespace App\Imports;

use App\Models\Category;
use App\Models\Brand;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\Attribute;
use App\Models\VariantAttribute;
use App\Models\PriceUpdate;
use App\Models\PriceLevelItem;
use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithStartRow;

class PricelistImport implements ToCollection, WithStartRow
{
    protected $priceUpdate;

    public function __construct()
    {
        $this->priceUpdate = PriceUpdate::create([
            'user_id' => 1,
            'effective_date' => now(),
            'ppn_rate' => 11.00,
            'location' => 'SBY',
            'price_type' => 'NORMAL',
            'notes' => 'Import from PRICELIST MASTER.xlsx'
        ]);
    }

    public function startRow(): int
    {
        return 1;
    }

    public function collection(Collection $rows)
    {
        $currentCategory = null;
        $headerRow = null;
        $isMksSection = false;

        foreach ($rows as $row) {
            if ($row->isEmpty()) continue;

            $data = $row->toArray();

            // Detect category
            if ($this->isCategoryHeader($data)) {
                $currentCategory = $this->getOrCreateCategory($data);
                continue;
            }

            // Detect normal vs MKS section
            if (isset($data[14]) && strpos($data[14], 'MKS') !== false) {
                $isMksSection = true;
                continue;
            }

            // Detect price header
            if ($this->isPriceHeader($data)) {
                $headerRow = $data;
                continue;
            }

            // Skip non-data rows
            if (!isset($data[0]) || empty(trim($data[0]))) continue;

            // Skip header rows like "Besi", "Diameter"
            if (in_array(trim($data[0]), ['Besi', 'Merek', 'MERK', 'Marking', 'Sebutan'])) continue;

            // Parse data row
            if ($currentCategory && $headerRow && $this->isValidData($data)) {
                $this->parseDataRow($data, $currentCategory, $headerRow, $isMksSection);
            }
        }
    }

    private function isCategoryHeader($data)
    {
        $text = isset($data[0]) ? trim($data[0]) : '';
        return in_array($text, [
            'BESI BETON',
            'BESI AS',
            'BESI POLOS',
            'BESI ULIR',
            'HOLLOW',
            'PLAT STRIP',
            'SIKU',
            'WF / HBEAM',
            'Pipa Spiral',
            'Sheetpile',
            'Wiremesh',
            'REJECT'
        ]);
    }

    private function getOrCreateCategory($data)
    {
        $name = trim($data[0]);
        return Category::firstOrCreate(['name' => $name], ['code' => $this->generateCode($name)]);
    }

    private function isPriceHeader($data)
    {
        return in_array('Hrg/kg', $data) || in_array('E-50', $data) || in_array('E', $data);
    }

    private function isValidData($data)
    {
        return isset($data[4]) && is_numeric(str_replace('.', '', $data[4])); // Harga/kg
    }

    private function parseDataRow($data, $category, $headerRow, $isMksSection)
    {
        // Ambil nama merek dari kolom 0
        $brandName = trim($data[0] ?? '');
        if (!$brandName) return;

        // Cari atau buat brand
        $brand = Brand::firstOrCreate(['name' => $brandName]);

        // Buat product
        $product = Product::firstOrCreate([
            'category_id' => $category->id,
            'brand_id' => $brand->id,
            'name' => $category->name
        ]);

        // Ambil diameter dari kolom 2
        $diameter = $data[2] ?? null;
        if (!$diameter) return;

        // Ambil KG dari kolom 3
        $kg = $data[3] ?? null;

        // Buat nama produk
        $name = $brandName . ' Ø' . $diameter;

        // Generate SKU
        $sku = $this->generateSku($product, $diameter);

        // Buat atau update variant
        $variant = ProductVariant::updateOrCreate(
            ['sku' => $sku],
            [
                'product_id' => $product->id,
                'name' => $name,
                'weight_per_unit' => $kg,
                'unit' => 'batang'
            ]
        );

        // Simpan atribut
        $this->saveVariantAttributes($variant, $diameter, $kg, $data[1] ?? null);

        // Harga per kg dari kolom 4
        $pricePerKg = $this->cleanNumber($data[4] ?? 0);

        if ($pricePerKg > 0) {
            $priceLevelItem = PriceLevelItem::updateOrCreate(
                [
                    'price_update_id' => $this->priceUpdate->id,
                    'variant_id' => $variant->id,
                    'price_level_id' => 1, // BASE
                ],
                [
                    'base_price_per_kg' => $pricePerKg,
                    'ppn_rate' => $this->priceUpdate->ppn_rate,
                ]
            );

            $priceLevelItem->generateCalculatedPrices();
        }
    }

    private function saveVariantAttributes($variant, $diameter, $kg, $marking = null)
    {
        $categoryId = $variant->product->category_id;

        // 1. Diameter
        $attr = Attribute::firstOrCreate([
            'category_id' => $categoryId,
            'name' => 'diameter'
        ]);
        $this->saveAttribute($variant->id, $attr->id, $diameter);

        // 2. KG
        if ($kg) {
            $attr = Attribute::firstOrCreate([
                'category_id' => $categoryId,
                'name' => 'kg'
            ]);
            $this->saveAttribute($variant->id, $attr->id, $kg);
        }

        // 3. Marking (bisa string, seperti 'YULI', 'SNI', dll)
        if ($marking) {
            $attr = Attribute::firstOrCreate([
                'category_id' => $categoryId,
                'name' => 'marking'
            ]);
            $this->saveAttribute($variant->id, $attr->id, $marking);
        }
    }

    /**
     * Simpan atribut dengan aman: numeric_value hanya diisi jika nilai numerik
     */
    private function saveAttribute($variantId, $attributeId, $value)
    {
        $numericValue = null;

        // Cek apakah nilai bisa diubah ke angka
        $cleaned = preg_replace('/[^\d\.]/', '', $value); // hapus selain angka dan titik
        if (is_numeric($cleaned)) {
            $numericValue = (float) $cleaned;
        }

        VariantAttribute::updateOrCreate(
            [
                'variant_id' => $variantId,
                'attribute_id' => $attributeId,
            ],
            [
                'value' => $value,
                'numeric_value' => $numericValue,
            ]
        );
    }

    private function cleanNumber($value)
    {
        return (float) preg_replace('/[^\d,\.]/', '', str_replace('.', '', $value));
    }

    private function generateCode($name)
    {
        return strtoupper(substr(preg_replace('/[^A-Za-z]/', '', $name), 0, 4));
    }

    private function generateSku($product, $diameter)
    {
        $brandCode = $product->brand->code ?? substr($product->brand->name, 0, 3);
        return strtoupper("{$product->category->code}-{$brandCode}-{$diameter}MM");
    }
}
