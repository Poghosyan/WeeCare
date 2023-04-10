<?php

namespace App\Http\Controllers;

use App\Models\Songs;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Validator;

class AlbumController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $songs = Songs::all();
        return response()->json([
            'products' => $songs
        ]);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Songs  $songs
     * @return \Illuminate\Http\Response
     */
    public function show(Songs $songs)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Songs  $songs
     * @return \Illuminate\Http\Response
     */
    public function edit(Songs $songs)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Songs  $songs
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Songs $songs)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Songs  $songs
     * @return \Illuminate\Http\Response
     */
    public function destroy(Songs $songs)
    {
        //
    }

    public function getSorted(Request $request, string $column1, string $column2 = 'id')
    {
        $columns = Schema::getColumnListing('songs');

        $validator = Validator::make(['sort' => [$column1, $column2] ], [
                'sort' => [
                    'required',
                    function ($attribute, $values, $fail) use ($columns) {
                        foreach ($values as $value) {
                            if (!in_array($value, $columns)) {
                                $str = 'The ' . $attribute . ' is invalid. Only allowed';
                                foreach ($columns as $column) {
                                    $str = "$str $column";
                                }
                                $fail($str . ".");
                            }
                        }
                    },
                ],
            ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()]);
        }

        $songs = Songs::orderBy($column1)->get();
        return response()->json([
            'products' => $songs
        ]);
    }
}
