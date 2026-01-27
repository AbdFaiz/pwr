<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RedemptionResource extends JsonResource
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
            'user_id' => $this->user_id,
            'reward_id' => $this->reward_id,
            'reward' => new RewardResource($this->whenLoaded('reward')),
            'points_used' => $this->points_used,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
