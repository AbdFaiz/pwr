<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed'
        ]);

        $user = User::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'customer'
        ]);

        // Create point balance entry
        $user->points()->create(['balance' => 0]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Customer registered successfully.',
            'user' => new UserResource($user),
            'token' => $token
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'credential' => 'required|string', // Ganti 'email' menjadi 'credential'
            'password' => 'required|string'
        ]);

        // Cek apakah input adalah email atau phone
        $field = filter_var($request->credential, FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';
    
        $user = User::where($field, $request->credential)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'credential' => ['The provided credentials are incorrect.']
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

         return response()->json([
            'status' => 'success',
            'message' => 'Logged in successfully.',
            'user' => new UserResource($user),
            'token' => $token
        ]);
    }
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully.'
        ]);
    }
}
