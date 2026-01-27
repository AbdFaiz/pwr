<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'invoice_number',
        'total_amount',
        'points_earned',
        'status',
        'file_path',
        'sales_code'
    ];

    protected $casts = [
        'total_amount' => 'decimal:2'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function sales()
    {
        return $this->belongsTo(User::class, 'sales_code', 'sales_code');
    }
    
    // Tambahkan accessor untuk file_url
	public function getFileUrlAttribute()
	{
	    return $this->file_path ? asset('storage/' . $this->file_path) : null;
	}
}
