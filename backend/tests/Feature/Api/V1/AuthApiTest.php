<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_and_receive_a_token(): void
    {
        $user = User::factory()->create([
            'email' => 'admin@example.com',
            'password' => 'secret-password',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => $user->email,
            'password' => 'secret-password',
            'device_name' => 'flutter-app',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('tokenType', 'Bearer')
            ->assertJsonPath('user.email', 'admin@example.com')
            ->assertJsonPath('abilities.0', 'employees:read')
            ->assertJsonPath('abilities.1', 'employees:write');

        $this->assertNotEmpty($response->json('accessToken'));
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_login_rejects_invalid_credentials(): void
    {
        User::factory()->create([
            'email' => 'admin@example.com',
            'password' => 'secret-password',
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'admin@example.com',
            'password' => 'wrong-password',
        ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('email');
    }

    public function test_authenticated_user_can_fetch_their_profile_and_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken(
            'test-client',
            ['employees:read', 'employees:write'],
        );

        $headers = [
            'Authorization' => 'Bearer '.$token->plainTextToken,
        ];

        $this->withHeaders($headers)
            ->getJson('/api/v1/auth/user')
            ->assertOk()
            ->assertJsonPath('data.email', $user->email);

        $this->withHeaders($headers)
            ->postJson('/api/v1/auth/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Logged out.');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}