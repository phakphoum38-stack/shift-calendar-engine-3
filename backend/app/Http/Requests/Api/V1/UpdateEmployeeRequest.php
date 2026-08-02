<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateEmployeeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $employee = $this->route('employee');

        return [
            'organization_id' => ['sometimes', 'nullable', 'uuid'],
            'branch_id' => ['sometimes', 'nullable', 'uuid'],
            'department_id' => ['sometimes', 'nullable', 'uuid'],
            'team_id' => ['sometimes', 'nullable', 'uuid'],

            'employee_code' => [
                'sometimes',
                'required',
                'string',
                'max:50',
                Rule::unique('employees', 'employee_code')->ignore($employee),
            ],

            'first_name' => ['sometimes', 'required', 'string', 'max:100'],
            'last_name' => ['sometimes', 'required', 'string', 'max:100'],
            'nickname' => ['sometimes', 'nullable', 'string', 'max:100'],
            'position' => ['sometimes', 'nullable', 'string', 'max:150'],

            'email' => [
                'sometimes',
                'nullable',
                'email',
                'max:255',
                Rule::unique('employees', 'email')->ignore($employee),
            ],

            'phone' => ['sometimes', 'nullable', 'string', 'max:30'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}