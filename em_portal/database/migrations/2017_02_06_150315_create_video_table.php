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
// | width     | int(11)          | YES  |     | NULL    |                |
// | height    | int(11)          | YES  |     | NULL    |                |
// | extension | varchar(10)      | YES  |     | NULL    |                |
// | created   | datetime         | YES  |     | NULL    |                |
// +-----------+------------------+------+-----+---------+----------------+
class CreateVideoTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('video')) {
            Schema::create('video', function (Blueprint $table) {
                $table->increments('id');
                $table->string('extension');
                $table->mediumText('url');
                $table->integer('reportID')->unsigned();
                $table->foreign('reportID')->references('id')->on('report')->onDelete('cascade');
                $table->integer('width');
                $table->integer('height');
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
        Schema::dropIfExists('video');
    }
}
