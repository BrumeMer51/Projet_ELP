import { Partie } from "./Partie.js";


let partie = new Partie("fichier.txt")
partie.init()
console.log(partie.l_joueurs[0].nom)
