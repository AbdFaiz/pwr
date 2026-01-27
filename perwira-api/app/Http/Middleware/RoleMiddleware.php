<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthenticated.'
            ], 401);
        }

        // Bisa multiple role, misalnya: role:sales|manager
        $allowedRoles = collect($roles)->flatMap(fn($r) => explode('|', $r))->toArray();

        if (!in_array($user->role, $allowedRoles)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized access.'
            ], 403);
        }

        return $next($request);
    }
}

