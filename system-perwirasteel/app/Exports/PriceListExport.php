<?php

namespace App\Exports;

use App\Models\ProductVariant;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use Maatwebsite\Excel\Concerns\WithEvents;
use Maatwebsite\Excel\Events\AfterSheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Alignment;

class PriceListExport implements FromCollection, WithHeadings, WithStyles, WithColumnWidths, WithEvents
{
    protected $variants;

    public function __construct($variants)
    {
        $this->variants = $variants;
    }

    public function collection()
    {
        return $this->variants->map(function ($variant) {
            $priceItem = $variant->priceLevelItems->first();
            if (!$priceItem) return null;

            $prices = $priceItem->calculatedPrices;

            $getRow = function ($type, $value) use ($prices) {
                $price = $prices->where('quantity_type', $type)->where($type === 'fixed' ? 'quantity' : 'percentage', $value)->first();
                return $price ? $price->total_price_with_ppn : '';
            };

            return [
                'name' => $variant->name,
                'kg' => $variant->weight_per_unit,
                'base_price_per_kg' => $priceItem->base_price_per_kg,
                'e50' => $getRow('fixed', 50),
                'e100' => $getRow('fixed', 100),
                'e150' => $getRow('fixed', 150),
                'e200' => $getRow('fixed', 200),
                'e250' => $getRow('fixed', 250),
                'e300' => $getRow('fixed', 300),
                'e350' => $getRow('fixed', 350),
                'e400' => $getRow('fixed', 400),
                'e450' => $getRow('fixed', 450),
                'e500' => $getRow('fixed', 500),
                'e550' => $getRow('fixed', 550),
                'e600' => $getRow('fixed', 600),
                'e650' => $getRow('percent', 8),
                'e700' => $getRow('percent', 9),
                'e750' => $getRow('percent', 10),
                'e800' => $getRow('percent', 11),
                'e850' => $getRow('percent', 12),
                'e900' => $getRow('percent', 13),
                'e950' => $getRow('percent', 14),
                'e1000' => $getRow('percent', 15), // jika ada
                'e1100' => $getRow('percent', 16),
                'e1150' => $getRow('percent', 17),
                'e1200' => $getRow('fixed', 1200),
            ];
        })->filter();
    }

    public function headings(): array
    {
        return [
            'Produk',
            'KG',
            'Harga/kg',
            'E50',
            'E100',
            'E150',
            'E200',
            'E250',
            'E300',
            'E350',
            'E400',
            'E450',
            'E500',
            'E550',
            'E600',
            'E650 (MKS)',
            'E700',
            'E750',
            'E800',
            'E850',
            'E900',
            'E950',
            'E1000',
            'E1100',
            'E1150',
            'E1200',
        ];
    }

    public function columnWidths(): array
    {
        return [
            'A' => 30,
            'B' => 8,
            'C' => 12,
            'D' => 12,
            'E' => 12,
            'F' => 12,
            'G' => 12,
            'H' => 12,
            'I' => 12,
            'J' => 12,
            'K' => 12,
            'L' => 12,
            'M' => 12,
            'N' => 12,
            'O' => 12,
            'P' => 14,
            'Q' => 12,
            'R' => 12,
            'S' => 12,
            'T' => 12,
            'U' => 12,
            'V' => 12,
            'W' => 12,
            'X' => 12,
            'Y' => 12,
            'Z' => 12,
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true]],
        ];
    }

    public function registerEvents(): array
    {
        return [
            AfterSheet::class => function (AfterSheet $event) {
                $sheet = $event->sheet->getDelegate();

                // Auto size columns
                foreach (range('A', 'Z') as $col) {
                    $sheet->getColumnDimension($col)->setAutoSize(true);
                }

                // Format angka
                $highestRow = $sheet->getHighestRow();
                $sheet->getStyle("C2:Z{$highestRow}")->getNumberFormat()->setFormatCode('#,##0');

                // Border
                $sheet->getStyle("A1:Z{$highestRow}")->getBorders()->getAllBorders()->setBorderStyle(Border::BORDER_THIN);

                // Align center for price columns
                $sheet->getStyle("D1:Z{$highestRow}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_RIGHT);

                // Header background
                $sheet->getStyle("A1:Z1")->getFill()->setFillType(\PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID)->getStartColor()->setARGB('FFF0F0F0');
            }
        ];
    }
}