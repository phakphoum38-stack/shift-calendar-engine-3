<?php

namespace Database\Factories;

use App\Models\Employee;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Employee>
 */
class EmployeeFactory extends Factory
{
    protected $model = Employee::class;

    public function definition(): array
    {
        return [
            'organization_id' => null,
            'branch_id' => null,
            'department_id' => null,
            'team_id' => null,
            'employee_code' => 'EMP-'.Str::upper(Str::random(8)),
            'first_name' => fake()->firstName(),
            'last_name' => fake()->lastName(),
            'nickname' => null,
            'position' => fake()->jobTitle(),
            'email' => fake()->unique()->safeEmail(),
            'phone' => null,
            'is_active' => true,
            'created_by' => null,
            'updated_by' => null,
        ];
    }
}