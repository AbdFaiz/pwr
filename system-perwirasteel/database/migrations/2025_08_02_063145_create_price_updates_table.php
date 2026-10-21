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
        Schema::create('price_updates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->date('effective_date');
            $table->decimal('ppn_rate', 5, 2)->default(11.00); // 11%
            $table->string('location')->nullable(); // SBY, MKS, JKT
            $table->string('price_type')->default('NORMAL'); // NORMAL, MKS
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('price_updates');
    }
};
