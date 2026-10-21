<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CalculatedPrice extends Model
{
    use HasFactory;

    protected $fillable = [
        'price_level_item_id', 'quantity_type', 'quantity', 'percentage',
        'price_per_kg', 'price_per_unit', 'total_price', 'total_price_with_ppn'
    ];

    public function priceLevelItem()
    {
        return $this->belongsTo(PriceLevelItem::class);
    }
}
