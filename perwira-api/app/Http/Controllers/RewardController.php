<?php

namespace App\Http\Controllers;

use App\Http\Resources\RewardResource;
use App\Models\Reward;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class RewardController extends Controller
{
    public function index()
    {
        $rewards = Reward::paginate(10);
        return RewardResource::collection($rewards);
    }

    public function show($id)
    {
       $reward = Reward::findOrFail($id);
       return response()->json([
            'message' => 'success',
            'data' => new RewardResource($reward)
       ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'points_required' => 'required|integer|min:1',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:10000'
        ]);

        $data = $request->only(['name', 'description', 'points_required']);
        $reward = new Reward();
        $reward->fill($data);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('rewards', 'public');
            $reward->image_path = $path;
        }

        $reward->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Reward created successfully.',
            'data' => new RewardResource($reward)
        ], 201);
    }

    public function update(Request $request, $id)
	{
	    $request->validate([
		'name' => 'sometimes|required|string|max:255',
		'description' => 'sometimes|required|string',
		'points_required' => 'sometimes|required|integer|min:1',
		'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:10000',
	    ]);

	    $reward = Reward::findOrFail($id);
	    $data = $request->only(['name', 'description', 'points_required']);
	    $reward->fill($data);

	    // Kalau upload baru
	    if ($request->hasFile('image')) {
		if ($reward->image_path) {
		    \Storage::disk('public')->delete($reward->image_path);
		}
		$path = $request->file('image')->store('rewards', 'public');
		$reward->image_path = $path;
	    }

	    $reward->save();

	    return response()->json([
		'status' => 'success',
		'message' => 'Reward updated successfully.',
		'data' => new \App\Http\Resources\RewardResource($reward)
	    ]);
	}

    public function destroy($id)
    {
        $reward = Reward::findOrFail($id);

        // Hapus gambar jika ada
        if ($reward->image_path) {
            Storage::disk('public')->delete($reward->image_path);
        }

        $reward->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Reward deleted successfully.'
        ]);
    }
}
