import { Tour } from "./Tour.js";

export class Joueur {
  constructor(nom) {
    this.nom = nom;
    this.statut = "Actif"
    this.total = 0;
    this.tours = new Tour;
  }

  affichageJoueur(indice) {
    /* On veut afficher : 
    Alice : 7,8,9    +4    Seconde chance   Total : 134
    */
    let tour = this.tours[indice]
    let chaine = ""
    for (let i = 0; i < tour.nombres.length; i ++) {
        chaine = chaine + tour.nombres[i]
        if (i != tour.nombres.length - 1) {
            chaine += ","
        }
    }
    chaine += "    "

    for (let i = 0; i < tour.modificateur.length; i ++) {
        chaine = chaine + tour.nombres[i]
        if (i != tour.modificateur.length - 1) {
            chaine += ","
        }
    }
    chaine += "    "

    if (tour.actions.length != 0) {
        chaine += tour.actions[0]
    }

    chaine += "    Total" + string(this.total)
    let res = this.nom + ":" + chaine
    return res
  }
}