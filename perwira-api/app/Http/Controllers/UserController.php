<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index()
    {
        $users = User::select('id', 'name', 'phone', 'address', 'company_name','email', 'role', 'sales_code', 'created_at')->paginate(10);

        return response()->json([
            'status' => 'success',
            'data' => $users,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed',
            'role' => 'required|in:customer,sales,manager',
            'address' => 'nullable|string|max:500', // tambahkan
            'company_name' => 'nullable|string|max:255',
	    'sales_code' => 'nullable|string|max:50|unique:users,sales_code', // tambahkan, unik
        ]);

        $user = User::create([
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'address' => $request->address,      // tambahkan
	    'company_name' => $request->company_name,
            'sales_code' => $request->sales_code, // tambahkan
        ]);

        // Jika bukan customer, tidak perlu points (opsional)
        if (in_array($request->role, ['customer', 'sales'])) {
            $user->points()->create(['balance' => 0]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'User created successfully.',
            'data' => new UserResource($user),
        ], 201);
    }

    public function show(User $user)
    {
        return response()->json([
            'status' => 'success',
            'data' => $user,
        ]);
    }

    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'phone' => 'nullable|string|max:20',
            'email' => 'sometimes|required|email|unique:users,email,'.$id,
            'password' => 'nullable|string|min:6|confirmed',
            'role' => 'sometimes|required|in:customer,sales,manager',
            'address' => 'nullable|string|max:500', // tambahkan
	    'company_name' => 'nullable|string|max:255',
            'sales_code' => 'nullable|string|max:50|unique:users,sales_code,'.$id, // tambahkan
        ]);

        $data = $request->only(['name', 'phone', 'email', 'role', 'address', 'company_name','sales_code']);

        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json([
            'status' => 'success',
            'message' => 'User updated successfully.',
            'data' => new UserResource($user),
        ]);
    }

    public function destroy($id)
    {
        $user = User::findOrFail($id);

        // Cegah hapus akun sendiri
        if ($user->id === request()->user()->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'You cannot delete your own account.',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'User deleted successfully.',
        ], 200);
    }
}
