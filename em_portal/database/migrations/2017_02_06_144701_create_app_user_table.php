<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;
// +----------+------------------+------+-----+---------+----------------+
// | Field    | Type             | Null | Key | Default | Extra          |
// +----------+------------------+------+-----+---------+----------------+
// | id       | int(11) unsigned | NO   | PRI | NULL    | auto_increment |
// | deviceID | varchar(100)     | YES  | UNI | NULL    |                |
// | apnToken | varchar(100)     | YES  |     | NULL    |                |
// | created  | datetime         | YES  |     | NULL    |                |
// +----------+------------------+------+-----+---------+----------------+
class CreateAppUserTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('user')) {
            Schema::create('user', function (Blueprint $table) {
                $table->increments('id');
                $table->string('deviceID');
                $table->string('apnToken');
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
        Schema::dropIfExists('user');
    }
}
