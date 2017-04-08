<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddAlertBoundsGeometryCoordinatesIdToAlertGeometryCoordinatesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('alert_geometry_coordinates', function (Blueprint $table) {
            //
            // $table->dropColumn('alertID');
            $table->integer('alertBoundID')->unsigned();
            $table->foreign('alertBoundID')->references('id')->on('alert_bounds_geometry_coordinates')->onDelete('cascade');

        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('alert_geometry_coordinates', function (Blueprint $table) {
            //
        });
    }
}
