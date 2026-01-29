import { Joueur } from "./Joueur.js";
import { Tour } from "./Tour.js";
import { Card } from "./Card.js"
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
        try {
            fs.writeFileSync(this.nom_fichier, "");
            console.log("Fichier créé avec succès !");
        } catch (err) {
            console.error("Erreur lors de la création du fichier:", err.message);
        }
        this.deck = this.create_deck()

        // Initialisation de la liste des joueurs :
        let valide = false
        let nb_joueurs = 0
        while (valide != true) {
            nb_joueurs = parseInt(prompt("Combien de joueurs ? "))
            if (nb_joueurs === 0 || nb_joueurs === 1) {
                console.log("Il faut au moins 2 joueurs")
            } else {
                valide = true
            }
        }

        for (let i = 0; i < nb_joueurs; i ++) {
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
            // Lancer la première distribution de cartes
            this.firstDistrib()
            // Tant que le tour doit continuer :
            while (this.resteActif()) {
                let i = 0
                // Pour chaque joueur, tant qu'on a pas un flip7 :
                while (!this.flip7 && i < this.l_joueurs.length ) {
                    let j = this.l_joueurs[i]
                    if (j.statut == "Actif") {
                        console.log("C'est le tour de ", j.nom)
                        console.log("Vos cartes sont : ")
                        console.log(j.affichageJoueur())
                        this.jouer(j)
                    }
                    i ++
                }

            }

            // A la fin d'un tour : 
            this.ecritureTour()
            for (const j of this.l_joueurs) {
                j.total += j.tour.somme()
                if (this.flip7 == j) {j.total += 15}
                j.tour = new Tour()
            }
            
        }
        this.endGame()

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

    initTour(){
        /* On incrémente le compteur de tour et on passe tous les joueurs en état actif */
        this.tour_courant += 1
        this.flip7 = null
        for (const j of this.l_joueurs) {
                j.statut = "Actif"
        }
        console.log("###### \n Tour ", this.tour_courant, "\n ###### \n")
    }

    firstDistrib(){
        for (const j of this.l_joueurs) {
            let carte = this.piocher_carte()
            this.appliquer_carte(j, carte)
        }
    }

    verifFinPartie() {
        let res = false
        for (let i = 0; i < this.l_joueurs.length; i ++) {
            if (this.l_joueurs[i].total >= 100) {
                res = true
            }
        }
        return res
    }

    endGame() {
        this.ajout_fichier("Points totaux : \n")
        for (const j of this.l_joueurs) {
            this.ajout_fichier(`${j.nom} : ${j.total} \n`)
        }
        let winner = this.l_joueurs[0]
        let max = winner.total
        for (const j of this.l_joueurs){
            if (j.total > max) {
                winner = j 
                max = j.total
            }
        }
        this.ajout_fichier(`Victoire de ${winner.nom} !!`)
        console.log("Victoire de ", winner.nom, " !!!")
    }

    resteActif(){
        let res = false
        for (const j of this.l_joueurs) {
            if (j.statut == "Actif") {
                res = true
            }
        }
        return res
    }

    ecritureTour() {
        this.ajout_fichier(`###### \n Tour ${this.tour_courant} \n######`)
        for (const j of this.l_joueurs){
            let infos = j.affichageJoueur()
            this.ajout_fichier(infos)
        }
        this.ajout_fichier("\n")

        console.log("Fichier mis à jour !")
    }

    ajout_fichier(string) {
    try {
        fs.appendFileSync(this.nom_fichier, "\n" + string);
        console.log("Ligne ajoutée !"); // Ligne de vérification, à enlever dans la version finale
    } catch (err) {
        console.error("Erreur lors de l'écriture:", err.message);
    }
    }

    jouer(joueur){
        let valide = false 
        while (!valide) {
            console.log("\n" + "=".repeat(40));
            console.log(`A ${joueur.nom} de jouer !`);
            console.log("=".repeat(40));
            console.log("1 -  Arrêter pour ce tour");
            console.log("2 -  Piocher une carte");
            console.log("=".repeat(40));
            
            let choix = prompt("➤ Votre choix : ");
            if (choix == "1"){
                joueur.statut = "Passif"
                console.log(joueur.nom, " se retire du tour \n")
                valide = true
            } else if (choix == "2") {
                console.log(joueur.nom, " décide de piocher ! \n")
                let nouvelle_carte = this.piocher_carte()
                this.appliquer_carte(joueur, nouvelle_carte)
                valide = true
            } else {
                console.log("Mauvaise entrée, réessayez \n")
            }
        }
    }

    piocher_carte() {
        let len = this.deck.length;
        // Si la pioche est vide, on reprend la défausse
        if (len == 0) {
            this.deck.push(this.defausse);
            this.deck = this.deck[0][0]
            this.defausse = [];
            len = this.deck.length;
            }
        let draw = this.randomInteger(0, len - 1);
        let card = this.deck.splice(draw, 1);
        console.log("Vous avez pioché : ", card[0].value, "\n");
        return card[0];
    }

    draw_three(personne){
        if (personne.statut === "Actif") {
            for (let i = 0; i < 3; i++){
                let carte = this.piocher_carte();
                this.appliquer_carte(personne, carte);
                
                // Si le joueur devient passif, on arrête
                if (personne.statut === "Passif") {
                    break;
                }
            }
        }
    }
    
    discard(deck) {
        for (const elem of deck)
            {this.defausse.push(elem);}
        deck = [];
        return deck;
    }

    joueur_defausse (personne){
        personne.tour.nombres = this.discard(personne.tour.nombres)
        personne.tour.modificateur = this.discard(personne.tour.modificateur)
        personne.tour.actions = this.discard(personne.tour.actions)
    }

    appliquer_carte(joueur, carte) {
    if (carte.type == 'action'){
    
        //ajouter carte au joueur
        let ok = false
        while (!ok){
            let qui = prompt("A qui donner cette action ? (No pour personne)")
            if (qui == "No"){
                this.defausse.push(carte)
                ok = true
            }
            else {
                let trouve = false
                for (const personne of this.l_joueurs){
                    if (personne.nom == qui){
                        if (personne.statut == "Actif") {
                            ok = true
                            trouve = true
                            if (carte.value == 'second_chance') {
                                if (personne.tour.actions == []){
                                    personne.tour.actions = [carte]
                                    ok = true
                                }
                                else {console.log("Ce joueur a déjà une seconde chance, réessaye.")} 
                                    this.appliquer_carte(joueur, carte)
                            }
                            else if (carte.value == 'freeze') {
                                this.joueur_defausse(personne)
                                personne.statut = "Passif"
                                this.defausse.push(carte)
                            }
                            else if (carte.value == 'draw_three') {
                                this.draw_three(personne)
                                this.defausse.push(carte)
                            }
                        }
                        else {console.log("Ce joueur est éliminé, réessaye.")}
                    }
                }
                if (!trouve) {
                    console.log("Ce joueur n'existe pas, réessaye.")
                }
            } 
        }
    }
    if (carte.type == 'number'){
        // Si la carte est déjà présente dans le jeu du joueur :
        for (const element of joueur.tour.nombres){
            if (element.value == carte.value) {
                if (joueur.tour.actions.length !== 0) {
                    console.log("Ouf, vous aviez une seconde chance !")
                    joueur.tour.actions = []
                } else {
                    joueur.statut = "Passif"
                    console.log("Dommage, ", joueur.nom,", vous aviez déjà un ", carte.value)
                }
            }
        }
        joueur.tour.nombres.push(carte)
        // Si le joueur perd, il défausse ses cartes
        if (joueur.statut == "Passif") {
            this.joueur_defausse(joueur)
        } else if (joueur.tour.nombres.length === 7){ // Si le joueur est actif et a 7 cartes différentes, alors il gagne ce round
            this.flip7 = joueur
            console.log("Wow, ", joueur.nom," a fait un flip7 !!!")
            for (const personne of joueur){
                personne.statut = "Passif"
            }
        }
    }
    if (carte.type == 'modif') {
        joueur.tour.modificateur.push(carte)
    }
    }

    randomInteger(min, max) {
        return Math.floor(Math.random() * (max - min + 1) ) + min;
    }

       
}
        
