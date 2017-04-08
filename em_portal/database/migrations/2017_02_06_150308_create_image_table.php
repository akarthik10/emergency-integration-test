<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

// +-----------+------------------+------+-----+---------+----------------+
// | Field     | Type             | Null | Key | Default | Extra          |
// +-----------+------------------+------+-----+---------+----------------+
// | id        | int(11) unsigned | NO   | PRI | NULL    | auto_increment |
// | reportID  | int(11) unsigned | YES  | MUL | NULL    |                |
// | url       | mediumtext       | YES  |     | NULL    |                |
// | extension | varchar(10)      | YES  |     | NULL    |                |
// | created   | datetime         | YES  |     | NULL    |                |
// +-----------+------------------+------+-----+---------+----------------+

class CreateImageTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('image')) {
            Schema::create('image', function (Blueprint $table) {
                $table->increments('id');
                $table->string('extension');
                $table->mediumText('url');
                $table->integer('reportID')->unsigned();
                $table->foreign('reportID')->references('id')->on('report')->onDelete('cascade');
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
        Schema::dropIfExists('image');
    }
}
