<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        // return parent::toArray($request);
        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'email' => $this->email,
            'role' => $this->role,
	    'points' => $this->points->balance ?? 0,
            'address' => $this->address,
	    'company_name' => $this->company_name,
	    'photo' => this->photo ? asset('storage/'.this->photo) : null,
            'sales_code' => $this->sales_code,
            'created_at' => $this->created_at,
        ];
    }
}
