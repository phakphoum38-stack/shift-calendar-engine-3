<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('employees', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('organization_id')->nullable()->index();
            $table->uuid('branch_id')->nullable()->index();
            $table->uuid('department_id')->nullable()->index();
            $table->uuid('team_id')->nullable()->index();

            $table->string('employee_code', 50)->unique();
            $table->string('first_name', 100);
            $table->string('last_name', 100);
            $table->string('nickname', 100)->nullable();
            $table->string('position', 150)->nullable();
            $table->string('email')->nullable()->unique();
            $table->string('phone', 30)->nullable();
            $table->boolean('is_active')->default(true);

            $table->uuid('created_by')->nullable()->index();
            $table->uuid('updated_by')->nullable()->index();

            $table->timestamps();
            $table->softDeletes();

            $table->index(['organization_id', 'department_id', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('employees');
    }
};
