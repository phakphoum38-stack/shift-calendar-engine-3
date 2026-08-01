<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreEmployeeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'organization_id' => ['nullable', 'uuid'],
            'branch_id' => ['nullable', 'uuid'],
            'department_id' => ['nullable', 'uuid'],
            'team_id' => ['nullable', 'uuid'],

            'employee_code' => [
                'required',
                'string',
                'max:50',
                Rule::unique('employees', 'employee_code'),
            ],

            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'nickname' => ['nullable', 'string', 'max:100'],
            'position' => ['nullable', 'string', 'max:150'],

            'email' => [
                'nullable',
                'email',
                'max:255',
                Rule::unique('employees', 'email'),
            ],

            'phone' => ['nullable', 'string', 'max:30'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}