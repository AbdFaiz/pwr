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
        Schema::create('product_variants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
            $table->string('sku')->unique(); // BETON-KSJI-10MM, PLAT-MIMI-3MM
            $table->string('name'); // Besi Beton KSJI Ø10, Plat MIMI 3x1200x2400
            $table->decimal('weight_per_unit', 10, 3)->nullable(); // kg per batang/lembar
            $table->string('unit')->default('unit'); // batang, lembar, meter, kg
            $table->decimal('length', 8, 2)->nullable(); // panjang per unit
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('product_variants');
    }
};
