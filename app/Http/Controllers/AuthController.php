<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use Illuminate\Http\Request;
use App\Facades\FirebaseAuthFacade as FirebaseAuth;

class AuthController extends Controller
{

    public function __construct(){
    }

    public function login(LoginRequest $request){
        $credentials = $request->only('email', 'password');
        try {

            $firebaseUser = FirebaseAuth::getFirebaseAuth($credentials['email'], $credentials['password']);
            $firebaseToken = $firebaseUser->idToken();
            if($firebaseToken){
                return response()->json(['connexion' => 'firestore', 'token' => $firebaseToken], 200);
            }
            return response()->json(['message' => 'Login ou mot de passe incorrect'], 401);
        } catch (\Kreait\Firebase\Exception\AuthException $e) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
    }
}
