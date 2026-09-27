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
            'title' => 'sometimes|string',
            'is_done' => 'sometimes|boolean'
        ]));
        return $task;
    }

    public function destroy(Task $task) { 
        $task->delete(); 
        return response()->noContent(); 
    }
}
