<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

// +-----------------+------------------+------+-----+---------+----------------+
// | Field           | Type             | Null | Key | Default | Extra          |
// +-----------------+------------------+------+-----+---------+----------------+
// | id              | int(11) unsigned | NO   | PRI | NULL    | auto_increment |
// | hazardType      | varchar(100)     | YES  |     | NULL    |                |
// | effective       | varchar(30)      | YES  |     | NULL    |                |
// | expires         | varchar(30)      | YES  |     | NULL    |                |
// | headline        | varchar(250)     | YES  |     | NULL    |                |
// | longDescription | text             | YES  |     | NULL    |                |
// | summary         | text             | YES  |     | NULL    |                |
// | validAt         | varchar(30)      | YES  |     | NULL    |                |
// | geometryType    | varchar(50)      | YES  |     | NULL    |                |
// +-----------------+------------------+------+-----+---------+----------------+
class CreateAlertsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('alert')) {
    //
            Schema::create('alert', function (Blueprint $table) {
                $table->increments('id');
                $table->string('hazardType');
                $table->string('effective');
                $table->string('expires');
                $table->string('headline');
                $table->text('longDescription');
                $table->text('summary');
                $table->string('validAt');
                $table->string('geometryType')->default('MultiPolygon');
                //Currently geometryType is not used 
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
        Schema::dropIfExists('alert');
    }
}
