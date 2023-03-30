<?php

namespace App\Console\Commands;

use App\Models\Songs;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class GetItunesMusic extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'get:iTunes';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $endpoint = "https://itunes.apple.com/us/rss/topalbums/limit=100/json";
        $client = new \GuzzleHttp\Client();

        $response = $client->request('GET', $endpoint);

        $statusCode = $response->getStatusCode();
        $content =  json_decode($response->getBody(), true);

        $formattedData = [];
        $time = now();
        foreach ($content['feed']['entry'] as $album) {
            $formattedData[] = [
                'name' => $album['im:name']['label'],
                'price' => $album['im:price']['attributes']['amount'],
                'title' => $album['title']['label'],
                'artist' => $album['im:artist']['label'],
                'category' => $album['category']['attributes']['label'],
                'created_at' => $time,
                'updated_at' => $time
            ];
        }
        Songs::insert($formattedData);
        Log::debug("Inserts have happened");
    }
}
