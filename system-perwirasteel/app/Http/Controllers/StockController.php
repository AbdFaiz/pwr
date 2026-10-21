<?php

namespace App\Http\Controllers;

use App\Models\ProductVariant;
use App\Models\Stock;
use Illuminate\Http\Request;
use Inertia\Inertia;

class StockController extends Controller
{
    public function index(Request $request)
    {
        $query = ProductVariant::with(['product.category', 'product.brand', 'stocks']);

        if ($request->category) {
            $query->whereHas('product.category', fn($q) => $q->where('name', 'like', "%{$request->category}%"));
        }

        $variants = $query->orderBy('name')->get()->map(function ($v) {
            $stock = $v->stocks ? $v->stocks : new Stock(['quantity' => 0, 'unit' => $v->unit]);
            return [
                'id' => $v->id,
                'name' => $v->name,
                'category' => $v->product->category->name,
                'brand' => $v->product->brand->name,
                'unit' => $v->unit,
                'kg' => $v->weight_per_unit,
                'current_stock' => $stock->quantity,
                'stock_unit' => $stock->unit,
                'location' => $stock->location ?? 'Gudang A',
                'last_updated' => $stock->updated_at?->format('d M Y'),
            ];
        });

        $categories = \App\Models\Category::orderBy('name')->pluck('name')->toArray();

        return Inertia::render('Stock/Index', [
            'variants' => $variants,
            'categories' => $categories,
            'filters' => $request->only('category')
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'stocks' => 'required|array',
            'stocks.*.variant_id' => 'exists:product_variants,id',
            'stocks.*.quantity' => 'required|numeric|min:0',
            'stocks.*.unit' => 'required|string',
            'stocks.*.location' => 'nullable|string',
        ]);

        foreach ($request->stocks as $stockData) {
            Stock::updateOrCreate(
                ['variant_id' => $stockData['variant_id']],
                [
                    'quantity' => $stockData['quantity'],
                    'unit' => $stockData['unit'],
                    'location' => $stockData['location'] ?? 'Gudang A',
                    'last_updated_by' => auth()->id(),
                ]
            );
        }

        return redirect()->route('stock.index')->with('success', 'Stok berhasil diupdate!');
    }
}