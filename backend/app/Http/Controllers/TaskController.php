<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->tasks()->latest()->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'completed' => 'boolean',
        ]);

        return $request->user()->tasks()->create($data);
    }

    public function show(Request $request, Task $task)
    {
        $this->authorizeTask($request, $task);

        return $task;
    }

    public function update(Request $request, Task $task)
    {
        $this->authorizeTask($request, $task);

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'completed' => 'boolean',
        ]);

        $task->update($data);

        return $task;
    }

    public function destroy(Request $request, Task $task)
    {
        $this->authorizeTask($request, $task);

        $task->delete();

        return response()->noContent();
    }

    private function authorizeTask(Request $request, Task $task): void
    {
        abort_if($task->user_id !== $request->user()->id, 403);
    }
}
