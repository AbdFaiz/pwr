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
        Schema::create('stocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('variant_id')->constrained('product_variants')->onDelete('cascade');
            $table->decimal('quantity', 12, 3);
            $table->string('unit')->default('batang'); // batang, lembar, kg, ton
        $table->text('notes')->nullable();
            $table->decimal('weight_kg', 12, 3)->nullable();
            $table->string('location')->nullable(); // Gudang A, B
            $table->foreignId('last_updated_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stocks');
    }
};
