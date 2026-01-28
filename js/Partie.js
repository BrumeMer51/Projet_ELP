import { Joueur } from "./Joueur.js";
import { Tour } from "./Tour.js";

import fs from "fs"

import promptSync from "prompt-sync";
const prompt = promptSync();

export class Partie {
    constructor(fichier) {
        this.nom_fichier = fichier;
        this.l_joueurs = [];
        this.deck = [];
        this.defausse = [];
        this.tour_courant = 0;
        this.flip7 = null
    }

    init() {
        // Création du fichier de la partie :
        fs.writeFile(this.nom_fichier, "Ecriture", (err) => 
            {
            if (err) {
                console.error("Erreur :", err);
            } else {
                console.log("Fichier créé ou mis à jour !");
            }
        });

        // Initialisation du deck : create_deck()

        // Initialisation de la liste des joueurs :
        let valide = false
        let nb_joueurs = 0
        while (valide != true) {
            nb_joueurs = parseInt(prompt("Combien de joueurs ? "))
            if (nb_joueurs == 0 || nb_joueurs == 1) {
                console.log("Il faut au moins 2 joueurs")
            } else {
                valide = true
            }
        }

        for (let i = 0; i < nb_joueurs; i ++) {
            let compteur = i
            let nom = prompt("Quel est le nom du joueur ? ")
            let joueur = new Joueur(nom)
            this.l_joueurs.push(joueur)
            }
    }

    jeu() {
        // On lance la partie :
        while (!this.verifFinPartie()) {
            // Initilisation d'un tour :
            this.initTour()
            /* Lancer la première distribution de cartes */

            // Tant que le tour doit continuer :
            while (!this.verifActifs()) {
                let i = 0
                // Pour chaque joueur, tant qu'on a pas un flip7 :
                while (!this.flip7 && i < this.l_joueurs.length ) {
                    let j = this.l_joueurs[i]
                    if (j.statut == "Actif") {
                        console.log("Vos cartes sont : ")
                        console.log(j.affichageJoueur())
                        jouer(j)
                    }
                    i ++
                }

            }

            // A la fin d'un tour : 
            this.ecritureTour()
            for (var j of this.l_joueurs) {
                j.total += j.tour.somme()
                j.tour = new Tour()
            }
            
        }

    }

    initTour(){
        /* On incrémente le compteur de tour et on passe tous les joueurs en état actif */
        this.tour_courant += 1
        this.flip7 = null
        for (var j of this.l_joueurs) {
                j.statut = "Actif"
        }
    }

    verifFinPartie() {
        let res = false
        for (let i = 0; i < this.l_joueurs.length; i ++) {
            if (this.l_joueurs[i].total >= 200) {
                res = true
            }
        }
        return res
    }

    verifActifs(){
        let res = false
        for (let i = 0; i < this.l_joueurs.length; i ++) {
            if (this.l_joueurs[i].statut == "Actif") {
                res = true
            }
        }
        return res
    }

    ecritureTour() {
        this.ajout_fichier(`Tour ${this.tour_courant}`)
        for (const j of this.l_joueurs){
            let infos = j.affichageJoueur()
            this.ajout_fichier(infos)
        }
        this.ajout_fichier("\n")

        console.log("Fichier mis à jour !")
    }

    ajout_fichier(string) {
        fs.appendFile(this.nom_fichier, "\n" + string, (err) => {
        if (err) console.error(err);
        else console.log("Ligne ajoutée !");
        });
    }

    jouer(joueur){
        let valide = false 
        while (!valide) {
            let choix = prompt("Que voulez vous faire ? \n 1)Rester \n 2)Piocher \n Choix : ")
            if (choix == "1"){
                joueur.statut = "Passif"
                valide = true
            } else if (choix == "2") {
                let nouvelle_carte = piocher_carte()
                appliquer_carte(joueur, nouvelle_carte)
                valide = true
            } else {
                console.log("Mauvaise entrée, réessayez \n")
            }
        }
    }
       
}
        




