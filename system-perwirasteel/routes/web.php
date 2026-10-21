<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ExportPriceListController;
use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Http\Controllers\PriceListController;
use App\Http\Controllers\PriceUpdateController;
use App\Http\Controllers\StockController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashaboard');

    Route::get('/pricelist', [PriceListController::class, 'index'])->name('pricelist.index');

    Route::get('/price-update/create', [PriceUpdateController::class, 'create'])->name('price-update.create');
    Route::post('/price-update', [PriceUpdateController::class, 'store'])->name('price-update.store');

    Route::get('/pricelist/export', [ExportPriceListController::class, 'export'])->name('pricelist.export');

    Route::get('/stock', [StockController::class, 'index'])->name('stock.index');
    Route::post('/stock/update', [StockController::class, 'update'])->name('stock.update');
});

require __DIR__.'/auth.php';
