<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'user' => $this->whenLoaded('user', new UserResource($this->user)),
            'total_amount' => $this->total_amount,
            'points_earned' => $this->points_earned,
            'status' => $this->status,
            'file_url' => $this->file_path ? asset('storage/' . $this->file_path) : null,
            'sales_code' => $this->sales_code,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
