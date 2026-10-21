<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\PricelistImport;
use App\Models\PriceLevel;

class ImportPricelistSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
    // Pastikan PriceLevel 'BASE' ada dengan id=1
    PriceLevel::firstOrCreate(
        ['code' => 'BASE'],
        [
            'name' => 'Harga Dasar',
            'description' => 'Harga per kg belum termasuk PPn',
            'is_active' => true
        ]
    );

        // Pastikan file di: storage/app/PRICELIST MASTER.xlsx
        Excel::import(new PricelistImport, storage_path('app/PRICELIST MASTER.xlsx'));
    }
}
