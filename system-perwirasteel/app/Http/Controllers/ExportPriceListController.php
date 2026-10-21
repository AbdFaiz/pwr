<?php

namespace App\Http\Controllers;

use App\Exports\PriceListExport;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

class ExportPriceListController extends Controller
{
    public function export()
    {
        $variants = ProductVariant::with([
            'product.category',
            'priceLevelItems.calculatedPrices'
        ])
        ->whereHas('priceLevelItems')
        ->orderBy('name')
        ->get();

        return Excel::download(new PriceListExport($variants), 'pricelist-master.xlsx');
    }
}
