# Self-hosted Windows Laravel deployment

The deployment workflow uses:

- GitHub-hosted Ubuntu for Composer install, Pint, migrations, and tests.
- A self-hosted Windows x64 runner for production deployment.

## Required runner labels

Register the Windows runner with these labels:

```text
self-hosted
Windows
X64
shift-calendar-deploy
```

## Deployment directory

The workflow deploys to:

```text
C:\Apps\shift-calendar-backend
```

Create the directory and production environment file before the first deployment:

```powershell
New-Item -ItemType Directory -Force C:\Apps\shift-calendar-backend
Copy-Item .\backend\.env.example C:\Apps\shift-calendar-backend\.env
```

Edit `C:\Apps\shift-calendar-backend\.env` with production settings and generate an application key from the deployment directory:

```powershell
Set-Location C:\Apps\shift-calendar-backend
php artisan key:generate
```

The Windows runner account must have write permission to the deployment directory. PHP 8.2 or newer and Composer 2 must be available in the runner service PATH.

## Preserved production data

Deployment preserves the server copies of:

- `.env`
- `database\database.sqlite`
- `storage\app`
- framework cache, sessions, and compiled views
- `storage\logs`
- `vendor`
- `node_modules`

The workflow runs production Composer install, database migrations, Laravel cache warm-up, and always attempts to leave maintenance mode.
