#!/usr/bin/env bash

cd em_portal 
{ echo '$admin = \App\Models\Role::where("name","=","admin")->first(); if (!$admin) { $admin = new \App\Models\Role(); $admin->name = "admin"; $admin->save(); }; $user = \App\Models\User::where("email","=","'"$1"'")->first(); $user->attachRole($admin); exit;' ; cat ; } | php artisan tinker
cd ..