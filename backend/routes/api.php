<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\EmployeeController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::post('auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('auth/user', [AuthController::class, 'user']);
        Route::post('auth/logout', [AuthController::class, 'logout']);

        Route::get('employees', [EmployeeController::class, 'index'])
            ->middleware('abilities:employees:read');
        Route::get('employees/{employee}', [EmployeeController::class, 'show'])
            ->middleware('abilities:employees:read');

        Route::post('employees', [EmployeeController::class, 'store'])
            ->middleware('abilities:employees:write');
        Route::match(['put', 'patch'], 'employees/{employee}', [EmployeeController::class, 'update'])
            ->middleware('abilities:employees:write');
        Route::delete('employees/{employee}', [EmployeeController::class, 'destroy'])
            ->middleware('abilities:employees:write');
    });
});