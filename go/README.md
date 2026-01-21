# Projet_ELP

Le code de la fonction principale de notre projet de filtre est Filtre_Image.go
Pour qu'il fonctionne, il faut éditer dans le code le chemin de l'image vers celui de l'image voulu.
Le nom de l'image après le traitement du filtre peut aussi être modifié depuis le code.

Les codes Serveur.go et Client.go sont comme, leurs noms l'indiquent, les versions serveur et client de la fonction de filtre.
Après exécution, le client demande à l'utilisateur d'entrer le chemin de l'image et le nom à donner à l'image filtrée. 
Le serveur crée la nouvelle image et renvoie un message indiquant que la tâche est réalisée.

Deux filtes sont gérés, un filtre noir et blanc qui renvoit l'image en teintes grises et un filtre de flou gaussien qui rend flou toute l'image sauf les bords.
