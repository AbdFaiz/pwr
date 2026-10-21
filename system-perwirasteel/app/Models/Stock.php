<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stock extends Model
{
    use HasFactory;

    protected $fillable = ['variant_id', 'quantity', 'weight_kg', 'location', 'last_updated_by'];

    public function variant()
    {
        return $this->belongsTo(ProductVariant::class);
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'last_updated_by');
    }
}
