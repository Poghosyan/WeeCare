<?php

namespace Tests\Feature\App\Http\Controllers\Api;

use App\Models\Songs;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Log;
use Tests\TestCase;

class AlbumController extends TestCase
{
    public function setUp(): void
    {
        parent::setUp();

        $this->setupDatabase();
    }

    /**
     * A basic feature test example.
     *
     * @return void
     */
    public function test_albums()
    {
        Songs::factory()->create();
        $response = $this->getJson('/api/albums');
        Log::debug(json_encode($response));
        $response->assertStatus(200);
    }
}
