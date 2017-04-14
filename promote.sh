#!/usr/bin/env bash

cd em_portal; { echo \"\$admin = new \App\Models\Role(); \$admin->name = 'admin'; \$admin->save(); \$admin = \App\Models\Role::where('name','=','admin')->first(); \$user = \App\Models\User::where('email','=','"+user+"')->first(); \$user->attachRole(\$admin); exit;\" ; cat ; } | php artisan tinker; cd ..; 