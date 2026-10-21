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
        Schema::create('calculated_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('price_level_item_id')->constrained('price_level_items')->onDelete('cascade');
            $table->enum('quantity_type', ['fixed', 'percent']);
            $table->integer('quantity')->nullable(); // 50, 100, 150, ..., 1200
            $table->decimal('percentage', 5, 2)->nullable(); // 1.00, 2.00, ..., 14.00
            $table->decimal('price_per_kg', 14, 2);
            $table->decimal('price_per_unit', 14, 2);
            $table->decimal('total_price', 16, 2);
            $table->decimal('total_price_with_ppn', 16, 2);
            $table->timestamps();

            $table->index(['quantity_type', 'quantity', 'percentage']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('calculated_prices');
    }
};
