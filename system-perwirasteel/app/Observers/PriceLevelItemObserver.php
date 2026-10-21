<?php

namespace App\Observers;

use App\Models\PriceLevelItem;

class PriceLevelItemObserver
{
    /**
     * Handle the PriceLevelItem "created" event.
     */
    public function created(PriceLevelItem $priceLevelItem): void
    {
        $priceLevelItem->generateCalculatedPrices();
    }

    /**
     * Handle the PriceLevelItem "updated" event.
     */
    public function updated(PriceLevelItem $priceLevelItem): void
    {
        $priceLevelItem->generateCalculatedPrices();
    }

    /**
     * Handle the PriceLevelItem "deleted" event.
     */
    public function deleted(PriceLevelItem $priceLevelItem): void
    {
        //
    }

    /**
     * Handle the PriceLevelItem "restored" event.
     */
    public function restored(PriceLevelItem $priceLevelItem): void
    {
        //
    }

    /**
     * Handle the PriceLevelItem "force deleted" event.
     */
    public function forceDeleted(PriceLevelItem $priceLevelItem): void
    {
        //
    }
}
