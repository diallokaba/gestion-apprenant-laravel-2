<?php

namespace App\Providers;

use App\Service\FirebaseAuthService;
use Illuminate\Support\ServiceProvider;

class FirebaseAuthProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton('firebaseauth', function(){
            return new FirebaseAuthService();
        });
    }

    public function boot(){

    }
}