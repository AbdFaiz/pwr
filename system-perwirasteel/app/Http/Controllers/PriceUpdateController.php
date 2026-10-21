<?php

namespace App\Http\Controllers;

use App\Models\ProductVariant;
use App\Models\PriceUpdate;
use App\Models\PriceLevel;
use App\Models\PriceLevelItem;
use Illuminate\Http\Request;
use Inertia\Inertia;

class PriceUpdateController extends Controller
{
    public function create()
    {
        $variants = ProductVariant::with('product.category', 'product.brand')
            ->orderBy('name')
            ->get()
            ->map(function ($v) {
                return [
                    'id' => $v->id,
                    'name' => $v->name,
                    'category' => $v->product->category->name,
                    'brand' => $v->product->brand->name,
                    'kg' => $v->weight_per_unit,
                ];
            });

        $basePriceLevelId = PriceLevel::where('code', 'BASE')->value('id');

        return Inertia::render('PriceUpdate/Create', [
            'variants' => $variants,
            'basePriceLevelId' => $basePriceLevelId,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'ppn_rate' => 'required|numeric|min:0',
            'effective_date' => 'required|date',
            'prices' => 'required|array',
            'prices.*.variant_id' => 'exists:product_variants,id',
            'prices.*.base_price_per_kg' => 'required|numeric|min:0',
        ]);

        $priceUpdate = PriceUpdate::create([
            'user_id' => auth()->id(),
            'effective_date' => $request->effective_date,
            'ppn_rate' => $request->ppn_rate,
            'location' => 'SBY',
            'price_type' => 'NORMAL',
            'notes' => $request->notes,
        ]);

        foreach ($request->prices as $priceData) {
            PriceLevelItem::updateOrCreate(
                [
                    'price_update_id' => $priceUpdate->id,
                    'variant_id' => $priceData['variant_id'],
                    'price_level_id' => $request->price_level_id,
                ],
                [
                    'base_price_per_kg' => $priceData['base_price_per_kg'],
                    'ppn_rate' => $request->ppn_rate,
                ]
            )->generateCalculatedPrices();
        }

        return redirect()->route('pricelist.index')->with('success', 'Harga berhasil diupdate!');
    }
}