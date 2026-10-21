<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PriceLevelItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'price_update_id',
        'variant_id',
        'price_level_id',
        'base_price_per_kg',
        'base_price_per_unit',
        'unit',
        'ppn_rate'
    ];

    public function priceUpdate()
    {
        return $this->belongsTo(PriceUpdate::class);
    }

    public function variant()
    {
        return $this->belongsTo(ProductVariant::class, 'variant_id');
    }

    public function priceLevel()
    {
        return $this->belongsTo(PriceLevel::class);
    }

    public function calculatedPrices()
    {
        return $this->hasMany(CalculatedPrice::class);
    }


    public function generateCalculatedPrices()
    {
        $this->calculatedPrices()->delete();

        $basePricePerKg = $this->base_price_per_kg;
        $ppnRate = $this->ppn_rate / 100;
        $weight = $this->variant->weight_per_unit;
        $pricePerUnit = $basePricePerKg * $weight;

        if (!$weight) return;

        // Fixed quantities: E50, E100, ..., E1200
        $fixedQtys = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000, 1100, 1150, 1200];

        foreach ($fixedQtys as $qty) {
            $total = $pricePerUnit * $qty;
            CalculatedPrice::create([
                'price_level_item_id' => $this->id,
                'quantity_type' => 'fixed',
                'quantity' => $qty,
                'price_per_kg' => $basePricePerKg,
                'price_per_unit' => $pricePerUnit,
                'total_price' => $total,
                'total_price_with_ppn' => $total * (1 + $ppnRate),
            ]);
        }

        // Percentage: E1% s/d E14%
        for ($i = 1; $i <= 14; $i++) {
            $multiplier = 1 + ($i / 100);
            $total = $pricePerUnit * ($i <= 7 ? 50 : 50 + ($i - 7) * 50) * $multiplier;
            CalculatedPrice::create([
                'price_level_item_id' => $this->id,
                'quantity_type' => 'percent',
                'percentage' => $i,
                'price_per_kg' => $basePricePerKg,
                'price_per_unit' => $pricePerUnit,
                'total_price' => $total,
                'total_price_with_ppn' => $total * (1 + $ppnRate),
            ]);
        }
    }
}
