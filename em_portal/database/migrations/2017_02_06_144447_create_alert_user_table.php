<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;
// +----------+------------------+------+-----+---------+----------------+
// | Field    | Type             | Null | Key | Default | Extra          |
// +----------+------------------+------+-----+---------+----------------+
// | id       | int(11) unsigned | NO   | PRI | NULL    | auto_increment |
// | username | varchar(250)     | YES  |     | NULL    |                |
// | alertID  | int(11) unsigned | YES  | MUL | NULL    |                |
// +----------+------------------+------+-----+---------+----------------+

class CreateAlertUserTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        //
        if (!Schema::hasTable('alert_user')) {
            Schema::create('alert_user', function (Blueprint $table) {
                $table->increments('id');
                $table->string('username');
                $table->integer('alertID')->unsigned();

                $table->foreign('alertID')->references('id')->on('alert')->onDelete('cascade');

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
        Schema::dropIfExists('alert_user');
    }
}
