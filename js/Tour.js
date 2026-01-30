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
        for (const nb of this.nombres){
            res_nb += parseInt(nb.value, 10)
        }
        for (const modif of this.modificateur){
            if (modif.value != "x2") {
                let ajout = modif.value.slice(1)
                res_bonus += parseInt(ajout, 10)
            }
            else {
                res_nb = res_nb*2
            }
        }
        return res_nb + res_bonus
    }
}
