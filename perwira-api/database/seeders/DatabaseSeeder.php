<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Point;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        User::create([
            'name' => 'faiz',
            'email' => 'faiz@gmail.com',
            'password' => Hash::make('faiz'),
            'role' => 'manager'
        ]);

        User::create([
            'name' => 'sales',
            'email' => 'sales@gmail.com',
            'password' => Hash::make('sales'),
            'role' => 'sales'
        ]);

        $cust = User::create([
            'name' => 'cust',
            'email' => 'cust@gmail.com',
            'password' => Hash::make('cust'),
            'role' => 'customer'
        ]);
        
        Point::create([
            'user_id' => $cust->id,
            'balance' => 0
        ]);
        
    }
}
