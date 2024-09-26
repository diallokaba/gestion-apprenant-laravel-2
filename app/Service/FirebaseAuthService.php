<?php

namespace App\Service;

use Illuminate\Support\Facades\File;
use Kreait\Firebase\Factory;

class FirebaseAuthService{
    
    private $firebase;
    public function __construct(){
        //$credentialsFirebaseJson = storage_path('app/gest-apprenant-laravel-firebase-adminsdk-iw06h-7cf3b600e8.json');
        
        // Chemin vers le fichier fire-auth.key
        $base64KeyFilePath = base_path('firebase-auth.key');

        // Lire le contenu du fichier (contenu en base64)
        $base64KeyContent = File::get($base64KeyFilePath);

        // Décoder le contenu base64
        $decodedJson = base64_decode($base64KeyContent);

        // Vérifier si le décodage a fonctionné
        if ($decodedJson === false) {
            throw new \Exception('Le décodage base64 a échoué.');
        }
        
        $credentialsFirebaseJson = json_decode($decodedJson, true);

        // Vérifier si la conversion en JSON a fonctionné
        if (is_null($credentialsFirebaseJson)) {
            throw new \Exception('La conversion en JSON a échoué. Vérifie que le contenu décodé est bien un JSON valide.');
        }

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