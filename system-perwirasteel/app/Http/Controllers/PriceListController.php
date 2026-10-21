<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Brand;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Collection;

class PriceListController extends Controller
{

public function index(Request $request)
{
    $query = ProductVariant::with([
        'product.category',
        'product.brand',
        'variantAttributes.attribute',
        'priceLevelItems.calculatedPrices'
    ])->whereHas('priceLevelItems');

    // Filter
    if ($request->category) {
        $query->whereHas('product.category', fn($q) => $q->where('name', 'like', "%{$request->category}%"));
    }

    $variants = $query->orderBy('name')->get();

    // Group by category
    $groupedVariants = $variants
        ->groupBy('product.category.name')
        ->map(function ($items) {
            return $items->map(function ($v) {
                return [
                    'id' => $v->id,
                    'name' => $v->name,
                    'unit' => $v->unit,
                    'weight_per_unit' => $v->weight_per_unit,
                    'product' => [
                        'category' => ['name' => $v->product->category->name],
                        'brand' => ['name' => $v->product->brand->name],
                    ],
                    'priceLevelItems' => $v->priceLevelItems->map(function ($item) {
                        return [
                            'base_price_per_kg' => $item->base_price_per_kg,
                            'calculatedPrices' => $item->calculatedPrices->map(function ($cp) {
                                return [
                                    'quantity_type' => $cp->quantity_type,
                                    'quantity' => $cp->quantity,
                                    'percentage' => $cp->percentage,
                                    'total_price_with_ppn' => $cp->total_price_with_ppn,
                                ];
                            }),
                        ];
                    }),
                    'variantAttributes' => $v->variantAttributes->map(function ($attr) {
                        return [
                            'attribute' => ['name' => $attr->attribute->name],
                            'value' => $attr->value,
                        ];
                    }),
                ];
            });
        })
        ->all(); // <-- penting: ubah ke array asosiatif PHP

    $categories = \App\Models\Category::orderBy('name')->pluck('name')->toArray();

    return Inertia::render('PriceList/Index', [
        'groupedVariants' => $groupedVariants, // ini akan dikirim ke React
        'filters' => $request->only(['category']),
        'categories' => $categories,
    ]);
}
}