<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Http;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/test-ocr', function () {
    $imagePath = storage_path('app/public/invoices/001.jpeg'); // ubah ke path kamu

    $response = Http::asMultipart()->post('https://api.ocr.space/parse/image', [
        'apikey' => env('OCR_SPACE_KEY'),
        'file' => fopen($imagePath, 'r'),
        'language' => 'eng',
        'isTable' => true, // bantu OCR.Space baca tabel
    ]);

    $result = $response->json();

    if (isset($result['ParsedResults'][0]['ParsedText'])) {
        return response()->json([
            'text' => $result['ParsedResults'][0]['ParsedText']
        ]);
    }

    return response()->json([
        'error' => $result['ErrorMessage'] ?? 'OCR failed',
        'response' => $result
    ], 500);
});

