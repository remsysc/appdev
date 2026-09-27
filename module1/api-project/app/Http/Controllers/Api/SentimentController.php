<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SentimentController extends Controller
{
    public function analyze(Request $request)
    {
        return response()->json([
            'label' => 'negative',
            'confidence' => 0.87
        ]);
    }
}
