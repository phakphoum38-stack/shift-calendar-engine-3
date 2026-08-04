<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CreateInitialAdminCommandTest extends TestCase
{
    use RefreshDatabase;

    protected function tearDown(): void
    {
        putenv('INITIAL_ADMIN_PASSWORD');
        unset($_ENV['INITIAL_ADMIN_PASSWORD'], $_SERVER['INITIAL_ADMIN_PASSWORD']);

        parent::tearDown();
    }

    public function test_it_creates_the_first_administrator_non_interactively(): void
    {
        $this->setInitialAdminPassword('Secure-Admin-123!');

        $this->artisan('admin:create-initial', [
            '--name' => 'Initial Administrator',
            '--email' => 'admin@example.com',
            '--no-interaction' => true,
        ])->assertSuccessful();

        $user = User::query()->sole();

        $this->assertSame('Initial Administrator', $user->name);
        $this->assertSame('admin@example.com', $user->email);
        $this->assertTrue($user->is_admin);
        $this->assertTrue(password_verify('Secure-Admin-123!', $user->password));
    }

    public function test_it_refuses_to_create_an_admin_when_a_user_already_exists(): void
    {
        User::factory()->create();
        $this->setInitialAdminPassword('Secure-Admin-123!');

        $this->artisan('admin:create-initial', [
            '--name' => 'Another Administrator',
            '--email' => 'another@example.com',
            '--no-interaction' => true,
        ])->assertFailed();

        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseMissing('users', [
            'email' => 'another@example.com',
        ]);
    }

    public function test_it_rejects_a_weak_password(): void
    {
        $this->setInitialAdminPassword('weak-password');

        $this->artisan('admin:create-initial', [
            '--name' => 'Initial Administrator',
            '--email' => 'admin@example.com',
            '--no-interaction' => true,
        ])->assertFailed();

        $this->assertDatabaseCount('users', 0);
    }

    private function setInitialAdminPassword(string $password): void
    {
        putenv("INITIAL_ADMIN_PASSWORD={$password}");
        $_ENV['INITIAL_ADMIN_PASSWORD'] = $password;
        $_SERVER['INITIAL_ADMIN_PASSWORD'] = $password;
    }
}
