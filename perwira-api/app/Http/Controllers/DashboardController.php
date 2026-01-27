<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Resources\UserResource;
use App\Http\Resources\InvoiceResource;
use App\Http\Resources\RedemptionResource;

class DashboardController extends Controller
{
    public function stats(Request $request)
    {
        $user = $request->user();
        
        // Dashboard untuk customer
        if ($user->role === 'customer') {
            return $this->customerDashboard($user);
        }
        
        // Dashboard untuk manager/sales (existing code)
        return response()->json([
            'total_users' => \App\Models\User::count(),
            'pending_invoices' => \App\Models\Invoice::where('status', 'pending')->count(),
            'total_rewards' => \App\Models\Reward::count(),
            'total_redemptions' => \App\Models\Redemption::count(),
        ]);
    }
    
    private function customerDashboard($user)
    {
        // Hitung invoice statistics untuk customer
        $totalInvoices = $user->invoices()->count();
        $pendingInvoices = $user->invoices()->where('status', 'pending')->count();
        $approvedInvoices = $user->invoices()->where('status', 'approved')->count();
        $totalEarnedPoints = $user->invoices()->where('status', 'approved')->sum('points_earned');
        
        // Recent activities - HANYA ambil data yang diperlukan, tanpa relationship sales
        $recentInvoices = $user->invoices()
            ->select('id', 'total_amount', 'points_earned', 'status', 'sales_code', 'created_at')
            ->latest()
            ->take(3)
            ->get()
            ->map(function ($invoice) {
                return [
                    'id' => $invoice->id,
                    'total_amount' => $invoice->total_amount,
                    'points_earned' => $invoice->points_earned,
                    'status' => $invoice->status,
                    'sales_code' => $invoice->sales_code,
                    'created_at' => $invoice->created_at,
                ];
            });
            
        $recentRedemptions = $user->redemptions()
            ->with('reward:id,name,points_required') // Hanya ambil field yang diperlukan
            ->select('id', 'reward_id', 'points_used', 'created_at')
            ->latest()
            ->take(3)
            ->get()
            ->map(function ($redemption) {
                return [
                    'id' => $redemption->id,
                    'reward_id' => $redemption->reward_id,
                    'reward_name' => $redemption->reward->name ?? 'Unknown Reward',
                    'points_used' => $redemption->points_used,
                    'created_at' => $redemption->created_at,
                ];
            });
        
        return response()->json([
            'user' => new UserResource($user),
            'points_summary' => [
                'current_points' => $user->points->balance ?? 0,
                'total_earned' => $totalEarnedPoints,
            ],
            'invoice_stats' => [
                'total' => $totalInvoices,
                'pending' => $pendingInvoices,
                'approved' => $approvedInvoices,
            ],
            'recent_activities' => [
                'invoices' => $recentInvoices,
                'redemptions' => $recentRedemptions,
            ]
        ]);
    }
}
