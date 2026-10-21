<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'sku',
        'name',
        'weight_per_unit',
        'unit',
        'length',
        'is_active'
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function variantAttributes()
    {
        return $this->hasMany(VariantAttribute::class, 'variant_id');
    }

    public function stocks()
    {
        return $this->hasOne(Stock::class);
    }

    public function priceLevelItems()
    {
        return $this->hasMany(PriceLevelItem::class, 'variant_id');
    }

    public function getAttributeValuesAttribute()
    {
        return $this->variantAttributes->mapWithKeys(function ($va) {
            return [$va->attribute->name => $va->value];
        });
    }
}
