<?php

namespace App\Http\Controllers;

use App\Http\Resources\InvoiceResource;
use App\Models\Invoice;
use App\Models\Point;
use App\Models\User;
use Illuminate\Http\Request;
use thiagoalessio\TesseractOCR\TesseractOCR;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class InvoiceController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'sales') {
            // Sales hanya lihat invoice yang cocok dengan sales_code-nya
            $invoices = Invoice::where('sales_code', $user->sales_code)->paginate(10);
        } else {
            // Customer lihat invoice miliknya
            $invoices = $user->invoices()->paginate(10);
        }

        return InvoiceResource::collection($invoices);
    }

    public function approve($id)
    {
        $invoice = Invoice::findOrFail($id);

        if ($invoice->status !== 'pending') {
            return response()->json([
                'status' => 'error',
                'message' => 'Only pending invoices can be approved.'
            ], 400);
        }

        $invoice->update(['status' => 'approved']);

        // Add points to customer
        $pointRecord = $invoice->user->points;
        $pointRecord->increment('balance', $invoice->points_earned);

        return response()->json([
            'status' => 'success',
            'message' => 'Invoice approved and points added.',
            'data' => new InvoiceResource($invoice)
        ]);
    }

    public function reject($id)
    {
        $invoice = Invoice::findOrFail($id);

        if ($invoice->status !== 'pending') {
            return response()->json([
                'status' => 'error',
                'message' => 'Only pending invoices can be rejected.'
            ], 400);
        }

        $invoice->update(['status' => 'rejected']);

        return response()->json([
            'status' => 'success',
            'message' => 'Invoice rejected.',
            'data' => new InvoiceResource($invoice)
        ]);
    }
    
    // For Cust
    public function store(Request $request)
{
    $request->validate([
        'total_amount' => 'required|numeric|min:0.01', // Validasi total_amount
        'sales_code' => 'required|string|exists:users,sales_code,role,sales',
        'file' => 'required|image|mimes:jpeg,png,jpg|max:10240' // max 10MB
    ]);

    $user = $request->user();

    // Simpan file
    $filePath = $request->file('file')->store('invoices', 'public');

    // Buat invoice record (tidak pakai OCR)
    $invoice = $user->invoices()->create([
        'total_amount' => $request->total_amount,
        'points_earned' => (int) floor($request->total_amount), // 1 poin per 1 rupiah
        'status' => 'pending',
        'file_path' => $filePath,
        'sales_code' => $request->sales_code
    ]);

    return response()->json([
        'status' => 'success',
        'message' => 'Invoice uploaded successfully.',
        'data' => new InvoiceResource($invoice)
    ], 201);
}
}
