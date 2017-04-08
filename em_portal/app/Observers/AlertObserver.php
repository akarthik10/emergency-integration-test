<?php

namespace App\Observers;

use App\Models\Alert;

class AlertObserver
{
    /**
     * Listen to the User created event.
     *
     * @param  User  $user
     * @return void
     */
    public function created(Alert $user)
    {
        //
    }

    /**
     * Listen to the User deleting event.
     *
     * @param  User  $user
     * @return void
     */
    public function deleting(Alert $user)
    {
        //
    }
}