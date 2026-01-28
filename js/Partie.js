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
        this.fin_tour = false;
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
            nb_joueurs = prompt("Combien de joueurs ? ")
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
        while (!this.verifFinPartie) {
            this.initTour()
            // Lancer la première distribution de cartes
            while (this.verifActifs) {
                for (let i = 0; i < this.l_joueurs.length; i ++) {
                    let j = this.l_joueurs[i]
                    if (j.statut == "Actif") {
                        console.log("Vos cartes sont : ")
                        j.affichageJoueur()
                        jouer(j, this.tour_courant, this.deck)
                    }
                }

            }
            
        }

    }

    initTour(){
        /* On incrémente le compteur de tour et on passe tous les joueurs en état actif */
        this.tour_courant += 1
        for (let i = 0; i < this.l_joueurs.length; i ++) {
                this.l_joueurs[i].statut = "Actif"
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
        this.ajout_fichier("Tour " + string(this.tour_courant))
        for (let i = 0; i < this.l_joueurs.length; i ++){
            let infos = this.l_joueurs[i].affichageJoueur()
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
       
}
        




