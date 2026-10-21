<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Models\PriceLevelItem;
use App\Observers\PriceLevelItemObserver;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        PriceLevelItem::observe(PriceLevelItemObserver::class);
    }
}
