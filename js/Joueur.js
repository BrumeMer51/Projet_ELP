import { Tour } from "./Tour.js";

export class Joueur {
  constructor(nom) {
    this.nom = nom;
    this.statut = "Actif"
    this.total = 0;
    this.tour = new Tour;
  }

  affichageJoueur() {
    /* On veut afficher : 
    Alice : 7,8,9    +4    Seconde chance   Total : 134
    */
    let chaine = ""
    for (let i = 0; i < this.tour.nombres.length; i ++) {
        chaine = chaine + this.tour.nombres[i].value
        if (i != this.tour.nombres.length - 1) {
            chaine += ","
        }
    }
    chaine += "    "

    for (let i = 0; i < this.tour.modificateur.length; i ++) {
        chaine = chaine + this.tour.modificateur[i].value
        if (i != this.tour.modificateur.length - 1) {
            chaine += ","
        }
    }
    chaine += "    "

    if (this.tour.actions.length != 0) {
        chaine += this.tour.actions[0].value
    }

    chaine += "    Total " + this.total
    let res = this.nom + ":" + chaine + "\n"
    return res
  }
}
