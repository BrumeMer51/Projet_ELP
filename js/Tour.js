export class Tour {
    constructor() {
        this.nombres = [];
        this.actions = [];
        this.modificateur = [];
    }

    somme() {
        let res_nb = 0
        let res_bonus = 0
        // On fait la somme des nombres :
        for (const nb in this.nombres){
            res_nb += parseInt(nb, 10)
        }
        for (const modif in this.modificateur){
            if (modif != "x2") {
                let ajout = modif.slice(1)
                res_bonus += ajout
            }
            else {
                res_nb = res_nb*2
            }
        }
        return res_nb + res_bonus
    }
}
