package main

// Definition de la fonction traitant une certaine bande d'image et renvoyant la bande filtrée
func traitement_bande(borne_sup int, borne_inf int, "canal chan"  ) {
	// Code traitement image
}

func main() {
	n := 4
	// Import de l'image
	// Récupération des dimensions
	// Division de l'image en n bande
	intervale := bounds.Max.Y % n
	b_inf := 0
	b_sup := 0
	// Pour chaque bande lancer la go routine
	for i := range n {
		b_inf = b_inf + intervale
		if i != n-1 {
			b_sup = b_inf + intervale
		} else {
			b_sup = bounds.Max.Y
		}

		go traitement_bande(paramètres)

}
