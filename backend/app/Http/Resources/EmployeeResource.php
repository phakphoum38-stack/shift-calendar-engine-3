<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmployeeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'organizationId' => $this->organization_id,
            'branchId' => $this->branch_id,
            'departmentId' => $this->department_id,
            'teamId' => $this->team_id,
            'employeeCode' => $this->employee_code,
            'firstName' => $this->first_name,
            'lastName' => $this->last_name,
            'nickname' => $this->nickname,
            'position' => $this->position,
            'email' => $this->email,
            'phone' => $this->phone,
            'isActive' => $this->is_active,
            'createdAt' => $this->created_at?->toISOString(),
            'updatedAt' => $this->updated_at?->toISOString(),
        ];
    }
}
