<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use App\Http\Resources\UserResource; 

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        return new UserResource($user);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
            'address' => 'nullable|string|max:500',
            'company_name' => 'nullable|string|max:255',
            'password' => 'nullable|string|min:6',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048' // Validasi foto
        ]);

        $data = $request->only(['name', 'phone', 'email', 'address', 'company_name']);

        // Handle upload foto
        if ($request->hasFile('photo')) {
            // Hapus foto lama jika ada
            if ($user->photo && Storage::exists('public/' . $user->photo)) {
                Storage::delete('public/' . $user->photo);
            }
            
            // Simpan foto baru
            $photoPath = $request->file('photo')->store('profiles', 'public');
            $data['photo'] = $photoPath;
        }

        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully.',
            'data' => new UserResource($user)
        ]);
    }

    // Endpoint khusus untuk menghapus foto profile
    public function deletePhoto(Request $request)
    {
        $user = $request->user();

        if ($user->photo && Storage::exists('public/' . $user->photo)) {
            Storage::delete('public/' . $user->photo);
            $user->update(['photo' => null]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Photo deleted successfully.',
            'data' => new UserResource($user)
        ]);
    }
}
