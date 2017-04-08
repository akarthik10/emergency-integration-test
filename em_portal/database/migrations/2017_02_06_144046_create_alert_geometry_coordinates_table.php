<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;
// +-----------+------------------+------+-----+---------+----------------+
// | Field     | Type             | Null | Key | Default | Extra          |
// +-----------+------------------+------+-----+---------+----------------+
// | id        | int(11) unsigned | NO   | PRI | NULL    | auto_increment |
// | latitude  | float(10,6)      | YES  |     | NULL    |                |
// | longitude | float(10,6)      | YES  |     | NULL    |                |
// | alertID   | int(11) unsigned | YES  | MUL | NULL    |                |
// +-----------+------------------+------+-----+---------+----------------+
class CreateAlertGeometryCoordinatesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('alert_geometry_coordinates')) {
            Schema::create('alert_geometry_coordinates', function (Blueprint $table) {
                $table->increments('id');
                $table->float('latitude', 10, 6);
                $table->float('longitude', 10, 6);
                // $table->integer('alertID')->unsigned();

                // $table->foreign('alertID')->references('id')->on('alert')->onDelete('cascade');

            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        //
        Schema::dropIfExists('alert_geometry_coordinates');
    }
}
