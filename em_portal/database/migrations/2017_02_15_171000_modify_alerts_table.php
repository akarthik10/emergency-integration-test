<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class ModifyAlertsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (Schema::hasTable('alert')) {
    //      
            Schema::table('alert', function (Blueprint $table) {
                $table->renameColumn('headline', 'title');
                $table->renameColumn('effective', 'startTime');
                $table->renameColumn('expires', 'expiryTime');
                $table->renameColumn('longDescription', 'body');
                $table->float('boundingLatitudeMin', 10, 6);
                $table->float('boundingLatitudeMax', 10, 6);
                $table->float('boundingLongitudeMin', 10, 6);
                $table->float('boundingLongitudeMax', 10, 6);
                $table->text('Polygons');
                $table->dropColumn(['validAt', 'geometryType']);
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
    }
}
