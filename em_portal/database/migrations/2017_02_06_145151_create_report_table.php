<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;
// +-------------+------------------+------+-----+--------------------+----------------+
// | Field       | Type             | Null | Key | Default            | Extra          |
// +-------------+------------------+------+-----+--------------------+----------------+
// | id          | int(11) unsigned | NO   | PRI | NULL               | auto_increment |
// | userID      | int(11) unsigned | YES  | MUL | NULL               |                |
// | sessionID   | varchar(250)     | YES  | MUL | NULL               |                |
// | lat         | decimal(10,6)    | YES  |     | NULL               |                |
// | lon         | decimal(10,6)    | YES  |     | NULL               |                |
// | title       | varchar(250)     | YES  |     | No title submitted |                |
// | description | text             | YES  |     | NULL               |                |
// | created     | datetime         | YES  |     | NULL               |                |
// +-------------+------------------+------+-----+--------------------+----------------+
class CreateReportTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('report')) {
            Schema::create('report', function (Blueprint $table) {
                $table->increments('id');
                $table->string('sessionID');
                $table->float('lat', 10, 6);
                $table->float('lon', 10, 6);
                $table->string('title');
                $table->text('description');
                $table->integer('userID')->unsigned();
                $table->foreign('userID')->references('id')->on('user')->onDelete('cascade');
                $table->dateTime('created');
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
        Schema::dropIfExists('report');
    }
}
