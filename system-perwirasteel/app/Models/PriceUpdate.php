<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PriceUpdate extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'effective_date', 'ppn_rate', 'location', 'price_type', 'notes'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(PriceLevelItem::class);
    }
}
