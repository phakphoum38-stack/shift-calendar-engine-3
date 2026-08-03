<?php

namespace Tests\Feature\Api\V1;

use App\Models\Employee;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class EmployeeApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_employee_routes_require_authentication(): void
    {
        $this->getJson('/api/v1/employees')
            ->assertUnauthorized();
    }

    public function test_it_lists_employees_with_read_ability(): void
    {
        Sanctum::actingAs(User::factory()->create(), ['employees:read']);
        Employee::factory()->count(2)->create();

        $this->getJson('/api/v1/employees')
            ->assertOk()
            ->assertJsonCount(2, 'data');
    }

    public function test_read_only_token_cannot_create_an_employee(): void
    {
        Sanctum::actingAs(User::factory()->create(), ['employees:read']);

        $this->postJson('/api/v1/employees', [
            'employee_code' => 'EMP-001',
            'first_name' => 'Somchai',
            'last_name' => 'Jaidee',
        ])->assertForbidden();
    }

    public function test_it_creates_an_employee_with_write_ability(): void
    {
        Sanctum::actingAs(User::factory()->create(), ['employees:write']);

        $response = $this->postJson('/api/v1/employees', [
            'employee_code' => 'EMP-001',
            'first_name' => 'Somchai',
            'last_name' => 'Jaidee',
            'nickname' => 'Chai',
            'position' => 'Radiologic Technologist',
            'email' => 'somchai@example.com',
            'is_active' => true,
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.employeeCode', 'EMP-001')
            ->assertJsonPath('data.firstName', 'Somchai')
            ->assertJsonPath('data.isActive', true);

        $this->assertDatabaseHas('employees', [
            'employee_code' => 'EMP-001',
            'first_name' => 'Somchai',
        ]);
    }

    public function test_it_validates_required_fields(): void
    {
        Sanctum::actingAs(User::factory()->create(), ['employees:write']);

        $this->postJson('/api/v1/employees', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'employee_code',
                'first_name',
                'last_name',
            ]);
    }

    public function test_it_updates_an_employee(): void
    {
        Sanctum::actingAs(User::factory()->create(), ['employees:write']);

        $employee = Employee::factory()->create([
            'first_name' => 'Old',
        ]);

        $this->patchJson("/api/v1/employees/{$employee->id}", [
            'first_name' => 'Updated',
        ])
            ->assertOk()
            ->assertJsonPath('data.firstName', 'Updated');

        $this->assertDatabaseHas('employees', [
            'id' => $employee->id,
            'first_name' => 'Updated',
        ]);
    }

    public function test_it_soft_deletes_an_employee(): void
    {
        Sanctum::actingAs(User::factory()->create(), ['employees:write']);

        $employee = Employee::factory()->create();

        $this->deleteJson("/api/v1/employees/{$employee->id}")
            ->assertNoContent();

        $this->assertSoftDeleted('employees', [
            'id' => $employee->id,
        ]);
    }
}
