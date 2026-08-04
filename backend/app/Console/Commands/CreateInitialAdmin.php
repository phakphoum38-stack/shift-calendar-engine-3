<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;

class CreateInitialAdmin extends Command
{
    protected $signature = 'admin:create-initial
        {--name= : Administrator display name}
        {--email= : Administrator email address}';

    protected $description = 'Create the first administrator account securely';

    public function handle(): int
    {
        if (User::query()->exists()) {
            $this->components->error(
                'A user account already exists. This command only creates the first administrator.',
            );

            return self::FAILURE;
        }

        $name = trim((string) ($this->option('name') ?: $this->ask('Administrator name')));
        $email = trim((string) ($this->option('email') ?: $this->ask('Administrator email')));
        $password = $this->resolvePassword();

        if ($password === null) {
            return self::FAILURE;
        }

        $validator = Validator::make(
            [
                'name' => $name,
                'email' => $email,
                'password' => $password,
            ],
            [
                'name' => ['required', 'string', 'max:255'],
                'email' => ['required', 'email', 'max:255', 'unique:users,email'],
                'password' => [
                    'required',
                    Password::min(12)
                        ->letters()
                        ->mixedCase()
                        ->numbers()
                        ->symbols(),
                ],
            ],
        );

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->components->error($error);
            }

            return self::FAILURE;
        }

        User::query()->create([
            'name' => $name,
            'email' => $email,
            'password' => $password,
            'is_admin' => true,
        ]);

        $this->components->info('Initial administrator created successfully.');
        $this->line('Email: '.$email);

        if (env('INITIAL_ADMIN_PASSWORD')) {
            $this->components->warn(
                'Remove INITIAL_ADMIN_PASSWORD from the environment now that setup is complete.',
            );
        }

        return self::SUCCESS;
    }

    private function resolvePassword(): ?string
    {
        $environmentPassword = env('INITIAL_ADMIN_PASSWORD');

        if (is_string($environmentPassword) && $environmentPassword !== '') {
            return $environmentPassword;
        }

        if (! $this->input->isInteractive()) {
            $this->components->error(
                'INITIAL_ADMIN_PASSWORD is required when running non-interactively.',
            );

            return null;
        }

        $password = (string) $this->secret('Administrator password');
        $confirmation = (string) $this->secret('Confirm administrator password');

        if (! hash_equals($password, $confirmation)) {
            $this->components->error('The password confirmation does not match.');

            return null;
        }

        return $password;
    }
}
