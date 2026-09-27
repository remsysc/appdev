#!/bin/bash
cd api-project

# Wait for artisan to exist
while [ ! -f artisan ]; do
  sleep 2
done

# We should also wait for composer install to finish.
# Let's check if the vendor directory has autoload.php
while [ ! -f vendor/autoload.php ]; do
  sleep 2
done

echo "Setting up APIs in Laravel"
php artisan install:api

# Create Task Model and Migration
php artisan make:model Task -m
MIGRATION_FILE=$(ls database/migrations/*_create_tasks_table.php | head -n 1)
cat << 'MIG' > "$MIGRATION_FILE"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->boolean('is_done')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
MIG

# Create AuditLog Model and Migration (for Lab 3)
php artisan make:model AuditLog -m
AUDIT_MIGRATION=$(ls database/migrations/*_create_audit_logs_table.php | head -n 1)
cat << 'AMIG' > "$AUDIT_MIGRATION"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->string('action');
            $table->unsignedBigInteger('task_id');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
AMIG

# Run migrations (use sqlite)
sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
touch database/database.sqlite
php artisan migrate --force

# Create Form Request (Lab 2)
php artisan make:request StoreTaskRequest
cat << 'REQ' > app/Http/Requests/StoreTaskRequest.php
<?php
namespace App\Http\Requests;
use Illuminate\Foundation\Http\FormRequest;

class StoreTaskRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    public function rules(): array {
        return [
            'title' => 'required|string|max:255',
            'is_done' => 'sometimes|boolean',
        ];
    }
}
REQ

# Create TaskController (Lab 1 & 2 & 3)
php artisan make:controller Api/TaskController --api
cat << 'CTRL' > app/Http/Controllers/Api/TaskController.php
<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\AuditLog;
use App\Http\Requests\StoreTaskRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TaskController extends Controller
{
    public function index() { 
        return Task::latest()->get(); 
    }

    public function store(StoreTaskRequest $request) { 
        // Lab 3: Transaction
        return DB::transaction(function () use ($request) {
            $task = Task::create($request->validated());
            AuditLog::create(['action' => 'task_created', 'task_id' => $task->id]);
            return $task;
        });
    }

    public function show(Task $task) { 
        return $task; 
    }

    public function update(Request $request, Task $task) {
        $task->update($request->validate([
            'title'=>'sometimes|string',
            'is_done'=>'sometimes|boolean'
        ]));
        return $task;
    }

    public function destroy(Task $task) { 
        $task->delete(); 
        return response()->noContent(); 
    }
}
CTRL

# Model Mass Assignment Updates
sed -i 's/use HasFactory;/use HasFactory;\n    protected $guarded = [];/' app/Models/Task.php
sed -i 's/use HasFactory;/use HasFactory;\n    protected $guarded = [];/' app/Models/AuditLog.php

# Register Routes
cat << 'RT' >> routes/api.php
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\TicketController;
use App\Http\Controllers\Api\SentimentController;

Route::apiResource('tasks', TaskController::class);
Route::post('sentiment', [SentimentController::class, 'analyze']);
Route::post('tickets', [TicketController::class, 'predict']);
RT

# Lab 2: Exception handling (bootstrap/app.php in Laravel 11+)
cat << 'BOOTSTRAP' > bootstrap/app.php
<?php
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Validation\ValidationException;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (ValidationException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json([
                    'error' => [
                        'code' => 'VALIDATION_FAILED',
                        'message' => 'The given data was invalid.',
                        'fields' => $e->errors(),
                    ],
                ], 422);
            }
        });
    })->create();
BOOTSTRAP

# Module 3 Lab 2 Laravel Controllers
php artisan make:controller Api/SentimentController
cat << 'SCTRL' > app/Http/Controllers/Api/SentimentController.php
<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class SentimentController extends Controller
{
    public function analyze(Request $request)
    {
        // Mocked as requested in Lab 1 example
        return response()->json([
            'label' => 'negative',
            'confidence' => 0.87
        ]);
    }
}
SCTRL

php artisan make:controller Api/TicketController
cat << 'TCTRL' > app/Http/Controllers/Api/TicketController.php
<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class TicketController extends Controller
{
    public function predict(Request $request)
    {
        $prediction = Http::post('http://localhost:8001/predict', [
            'text' => $request->input('description'),
        ])->json();

        return response()->json([
            'id' => rand(1, 100),
            'description' => $request->input('description'),
            'suggested_category' => $prediction['category'] ?? 'unknown'
        ]);
    }
}
TCTRL

echo "Done"
