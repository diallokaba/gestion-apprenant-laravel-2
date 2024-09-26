<?php

namespace App\Service;

use Kreait\Firebase\Factory;

class FirebaseAuthService{
    
    private $firebase;
    public function __construct(){
        $credentialsFirebaseJson = storage_path('app/gest-apprenant-laravel-firebase-adminsdk-iw06h-7cf3b600e8.json');
        $this->firebase = (new Factory)->withServiceAccount($credentialsFirebaseJson);
    }

    public function getFirebaseAuth($email, $password){
        $firebaseAuth = $this->firebase->createAuth();
        return $firebaseAuth->signInWithEmailAndPassword($email, $password);
    }

    public function firestore(){
        return $this->firebase->createFirestore();
    }
}