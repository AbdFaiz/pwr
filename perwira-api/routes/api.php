<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\InvoiceController;
use App\Http\Controllers\RewardController;
use App\Http\Controllers\RedemptionController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Route::post('/register', [AuthController::class, 'register'])->name('register');
Route::post('/login', [AuthController::class, 'login'])->name('login');
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    Route::get('/dashboard-stats', [DashboardController::class, 'stats']);

    // Profile
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::delete('/profile/photo', [ProfileController::class, 'deletePhoto']);

    // Users CRUD
    Route::apiResource('users', UserController::class)->middleware('role:manager');

    // Invoices
    Route::apiResource('invoices', InvoiceController::class)->except(['update', 'destroy']);
    Route::put('/invoices/{id}/approve', [InvoiceController::class, 'approve'])->middleware('role:sales');
    Route::put('/invoices/{id}/reject', [InvoiceController::class, 'reject'])->middleware('role:sales');

    // Rewards
    Route::get('/rewards', [RewardController::class, 'index']);
    Route::middleware('role:sales|manager')->group(function () {
        Route::post('/rewards', [RewardController::class, 'store']);
	Route::get('/rewards/{id}', [RewardController::class, 'show']);
        Route::put('/rewards/{id}', [RewardController::class, 'update']);
        Route::delete('/rewards/{id}', [RewardController::class, 'destroy']);
    });

    // Redemptions
    Route::post('/redemptions', [RedemptionController::class, 'store']);
    Route::get('/redemptions', [RedemptionController::class, 'index']);
});

//Route::get('/users', function (Request $request) {
//    return $request->user();
//})->middleware('auth:sanctum');
