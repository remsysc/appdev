<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\TicketController;
use App\Http\Controllers\Api\SentimentController;

Route::apiResource('tasks', TaskController::class);
Route::post('sentiment', [SentimentController::class, 'analyze']);
Route::post('tickets', [TicketController::class, 'predict']);
