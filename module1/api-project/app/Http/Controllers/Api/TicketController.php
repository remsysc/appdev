<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class TicketController extends Controller
{
    public function predict(Request $request)
    {
        $prediction = Http::post(env('AI_SERVICE_URL', 'http://localhost:8001/predict'), [
            'text' => $request->input('description'),
        ])->json();

        return response()->json([
            'id' => rand(1, 100),
            'description' => $request->input('description'),
            'suggested_category' => $prediction['category'] ?? 'unknown'
        ]);
    }
}
