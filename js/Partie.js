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
        this.deck = this.create_deck()

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

    
    create_deck() {
        const card0 = new Card("number", 0);
        let deck = [];
        deck.push(card0);
        for(let numberi = 1; numberi <= 12; numberi = numberi + 1) {
            for(let numberj = numberi; numberj <= 12; numberj = numberj + 1) {
                const card = new Card("number", String(numberj))
                deck.push(card);
                }
            }
        //add actions and bonus
        for(let i = 0; i <=2; i = i + 1){
            const card = new Card("action", "freeze")
            deck.push(card);
        }
        for(let i = 0; i <=2; i = i + 1){
            const card = new Card("action", "second_chance")
            deck.push(card);
        }
        for(let i = 0; i <=2; i = i + 1){
            const card = new Card("action", "draw_three")
            deck.push(card);
        }
        for(let i = 1; i <=5; i = i + 1){
            const card = new Card("modif", "+" + String(2 * i))
            deck.push(card);
        }
        const card2 = new Card("modif", "x 2")
        deck.push(card2);  
        return deck;
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

    piocher_carte() {
        let len = this.deck.length;
        if (len == 0) {
            this.deck.push(this.defausse);
            this.deck = this.deck[0][0]
            this.defausse = [];
            len = this.deck.length;
            }
        let draw = randomInteger(0, len);
        let card = this.deck.splice(draw, 1);
        console.log(card[0]);
        return card[0];
    }

    draw_three(personne){
        for (i = 0; i < 3; i = i + 1){
            if (personne.statut == "Active")
                carte = this.piocher_carte()
                this.appliquer_carte(personne, carte)
        }
    }
    
    discard(deck) {
        for (const elem in deck)
            {this.defausse.push(elem);}
        deck = [];
        return deck;
        }

    joueur_defausse (personne){
        personne.deck = discard(personne.tours.nombres)
        personne.deck = discard(personne.tours.modificateur)
        personne.deck = discard(personne.tours.actions)
    }

    appliquer_carte(joueur, carte) {
    if (carte.type == 'action'){
    
        //ajouter carte au joueur
        let ok = false
        while (!ok){
            let qui = prompt("A qui donner cette action ? (No pour personne)")
            if (qui == "No"){
                this.defausse.push(carte)
            }
            else{
                for (const personne of this.l_joueurs){
                    if (personne.nom == qui){
                        if (personne.statut == "Active") {
                            if (carte.value == 'second_chance') {
                                if (personne.tours.modificateur = []){
                                    personne.tours.modificateur = [carte]
                                    ok = true
                                }
                                else {console.log("Ce joueur a déjà une seconde chance, réessaye.")}
                            }
                            else if (carte.value == 'freeze') {
                                joueur_defausse (personne)
                                personne.statut = "Passive"
                                this.defausse.push(carte)
                            }
                            else if (carte.value == 'draw_three') {
                                this.draw_three(player)
                                this.defausse.push(carte)
                            }
                        }
                        else {console.log("Ce joueur est eliminé, réessaye.")}
                    }
                    else {console.log("Ce joueur n'existe pas, réessaye.")}
                }
            }
        }
    }
    if (carte.type == 'value'){
        for (const element of joueur.tours.nombres){
            if (element == carte) {
                joueur.statut = "Lost"
            }
        }
        joueur.tours.push(carte)
        if (joueur.statut == "Lost") {
            deck, discard = defausse(deck, discard)
        }
    }
    if (carte.type == 'modif') {
        joueur.modif.push(carte)
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
        





