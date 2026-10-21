<?php

namespace App\Http\Controllers;

use App\Models\ProductVariant;
use App\Models\PriceUpdate;
use App\Models\Stock;
use App\Models\PriceLevelItem;
use Illuminate\Http\Request;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index()
    {
        // Harga terbaru
        $latestPriceUpdate = PriceUpdate::latest()->first();

        $recentPriceChanges = PriceLevelItem::with(['variant.product.category', 'variant'])
            ->whereHas('priceUpdate', function ($q) use ($latestPriceUpdate) {
                $q->where('id', $latestPriceUpdate?->id);
            })
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        // Stok rendah
        $lowStock = Stock::with('variant')
            ->where('quantity', '<', 10)
            ->orderBy('quantity')
            ->limit(5)
            ->get();

        // Info penting dari Excel (bisa disimpan di database atau hardcode dulu)
        $importantInfo = [
            'bundle' => [
                '6 SNI' => '200 batang',
                '8 SNI' => '200 batang',
                '10 SNI' => '200 batang',
                '13 SNI' => '100 batang',
                '16 SNI' => '75 batang',
            ],
            'mks_update' => 'Update harga MKS per 17/03/25: Rp 11.800.000,- /20feet',
            'paku' => [
                '1.5"' => 'PLUS 500',
                '1.75"' => 'PLUS 300',
                '2"' => 'PLUS 200',
            ],
            'kontainer_makassar' => '20 FT: 10.3 JUTA | 40 FT: 17.6 JUTA',
        ];

        return Inertia::render('Dashboard/Index', [
            'recentPriceChanges' => $recentPriceChanges,
            'lowStock' => $lowStock,
            'importantInfo' => $importantInfo,
            'latestPriceUpdate' => $latestPriceUpdate,
        ]);
    }
}