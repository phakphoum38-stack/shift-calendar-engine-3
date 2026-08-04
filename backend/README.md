# Shift Calendar Engine API

Laravel 12 API backend for Shift Calendar Engine 3. It provides Sanctum authentication and employee management endpoints for the Flutter application.

## Requirements

- PHP 8.2 or newer
- Composer 2
- SQLite for the default local setup, or MySQL/PostgreSQL configured in `.env`
- Flutter SDK for the client application

## Windows PowerShell setup

From the repository root:

```powershell
cd backend
composer install
Copy-Item .env.example .env
php artisan key:generate
php artisan migrate
```

The default configuration uses SQLite. Laravel creates or uses `database/database.sqlite` according to the application configuration.

Start the API:

```powershell
php artisan serve --host=127.0.0.1 --port=8000
```

Keep this terminal open while using the Flutter application.

## Create the first administrator securely

Create the initial administrator only after migrations have completed:

```powershell
php artisan admin:create-initial
```

The command:

- refuses to run when any user already exists;
- asks for the administrator name and email;
- reads the password through a hidden prompt;
- requires at least 12 characters with upper- and lower-case letters, numbers, and symbols;
- stores the password using Laravel's hashed cast;
- marks the account with `is_admin=true`;
- never writes a default password to the repository.

Do not create production accounts with Tinker or a hard-coded database seeder.

### Non-interactive provisioning

For a controlled deployment environment, provide the password through a temporary environment secret and pass the non-secret fields as options:

```powershell
$env:INITIAL_ADMIN_PASSWORD = '<strong-secret-from-your-secret-manager>'
php artisan admin:create-initial --name="System Administrator" --email="admin@example.com" --no-interaction
Remove-Item Env:INITIAL_ADMIN_PASSWORD
```

Never commit the password to `.env`, shell scripts, workflow files, screenshots, or documentation. Remove the temporary secret immediately after the command succeeds.

If a user already exists, the command exits without changing the database. This prevents accidental replacement or creation of an additional privileged account.

## Run the Flutter client

Open another PowerShell window at the repository root:

```powershell
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

For Android Emulator, use:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a physical device on the same network, start Laravel on all interfaces and use the computer's LAN address:

```powershell
php artisan serve --host=0.0.0.0 --port=8000
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000
```

Replace `192.168.1.100` with the API computer's actual local IP address. Do not expose the Laravel development server directly to the public internet.

## Authentication endpoints

```text
POST /api/v1/auth/login
GET  /api/v1/auth/user
POST /api/v1/auth/logout
```

Login request:

```json
{
  "email": "admin@example.com",
  "password": "your-password",
  "device_name": "Shift Calendar Engine Windows"
}
```

Successful login returns a Sanctum Bearer token. Protected requests must include:

```http
Authorization: Bearer <token>
Accept: application/json
```

## Employee endpoints

```text
GET    /api/v1/employees
GET    /api/v1/employees/{employee}
POST   /api/v1/employees
PUT    /api/v1/employees/{employee}
PATCH  /api/v1/employees/{employee}
DELETE /api/v1/employees/{employee}
```

These routes require Sanctum authentication and the corresponding `employees:read` or `employees:write` token ability.

## Verification

Run backend tests and formatting checks:

```powershell
php artisan test
vendor\bin\pint --test
```

Inspect registered API routes:

```powershell
php artisan route:list --path=api/v1
```

## Common problems

### `vendor/autoload.php` is missing

Install Composer dependencies from the `backend` directory:

```powershell
composer install
```

### `No application encryption key has been specified`

```powershell
php artisan key:generate
```

### Login reports incorrect credentials

Confirm that the first administrator was created and that the email matches exactly:

```powershell
php artisan tinker --execute="dump(App\Models\User::query()->select('id', 'name', 'email', 'is_admin')->get()->toArray());"
```

Do not print password hashes or access tokens in shared logs.

### Port 8000 is already in use

Stop the other process or use another port, then pass the same URL to Flutter:

```powershell
php artisan serve --host=127.0.0.1 --port=8001
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8001
```

## Production checklist

Before deployment:

- set `APP_ENV=production` and `APP_DEBUG=false`;
- use HTTPS and a production web server instead of `php artisan serve`;
- store secrets in the deployment platform's secret manager;
- use a production database with backups;
- run `php artisan migrate --force` during a controlled release;
- create the initial administrator once, then remove the provisioning secret;
- restrict database, filesystem, and server permissions;
- rotate exposed credentials and revoke unused Sanctum tokens;
- run the test and formatting checks before release.
