<?php

namespace App\Http\Controllers;

use App\Http\Resources\RedemptionResource;
use App\Models\Redemption;
use App\Models\Reward;
use App\Models\Point;
use Illuminate\Http\Request;

class RedemptionController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        // Manager & sales bisa lihat semua redemption
        // Customer hanya lihat miliknya
        if ($user->role === 'manager' || $user->role === 'sales') {
            $redemptions = Redemption::with('user', 'reward')->paginate(10);
        } else {
            $redemptions = $user->redemptions()->with('reward')->paginate(10);
        }

        return RedemptionResource::collection($redemptions);
    }

    public function store(Request $request)
    {
        $request->validate([
            'reward_id' => 'required|exists:rewards,id'
        ]);

        $user = $request->user();
        $reward = Reward::findOrFail($request->reward_id);

        // 🔐 Ambil poin dari database, bukan dari input frontend
        $pointBalance = $user->points->balance;

        if ($pointBalance < $reward->points_required) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient points to redeem this reward.'
            ], 400);
        }

        // 🔐 Ambil points_required dari database (aman)
        $pointsUsed = $reward->points_required;

        // Kurangi poin customer
        $user->points()->decrement('balance', $pointsUsed);

        // Buat redemption record
        $redemption = $user->redemptions()->create([
            'reward_id' => $reward->id,
            'points_used' => $pointsUsed
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Redemption successful.',
            'data' => new RedemptionResource($redemption)
        ], 201);
    }
}
