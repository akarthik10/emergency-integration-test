<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateAlertBoundsGeometryCoordinatesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('alert_bounds_geometry_coordinates', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('alertID')->unsigned();
            $table->foreign('alertID')->references('id')->on('alert')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('alert_bounds_geometry_coordinates');
    }
}
