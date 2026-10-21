<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('price_level_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('price_update_id')->constrained('price_updates')->onDelete('cascade');
            $table->foreignId('variant_id')->constrained('product_variants')->onDelete('cascade');
            $table->foreignId('price_level_id')->constrained('price_levels')->onDelete('cascade');
            $table->decimal('base_price_per_kg', 14, 2)->nullable();
            $table->decimal('base_price_per_unit', 14, 2)->nullable();
            $table->string('unit')->default('kg');
            $table->decimal('ppn_rate', 5, 2)->nullable(); // override global
            $table->timestamps();

            // $table->unique(['price_update_id', 'variant_id', 'price_level_id'], 'pli_update_variant_level_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('price_level_items');
    }
};
