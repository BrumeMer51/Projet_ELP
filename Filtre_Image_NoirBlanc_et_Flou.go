package main

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"log"
	"math"
	"os"
	"sync"
)

const (
	taille = 21
)

func creation_matrice() [taille][taille]float64 {
	var tab [taille][taille]float64
	sigma := float64((taille - 1)) / 6.0
	centre := float64((taille - 1)) / 2.0

	somme := 0.0
	// Calcul de tous les coefficients
	for i := 0; i < taille; i++ {
		for j := 0; j < taille; j++ {
			tab[i][j] = (1 / (2 * math.Pi * math.Pow(sigma, 2))) * math.Exp((-math.Pow(centre-float64(i), 2)-math.Pow(centre-float64(j), 2))/2*math.Pow(sigma, 2))
			somme += tab[i][j]
		}
	}

	// Normalisation des coefficients
	for i := 0; i < taille; i++ {
		for j := 0; j < taille; j++ {
			tab[i][j] = tab[i][j] / somme
		}
	}

	return tab
}

// Definition de la fonction traitant une certaine bande d'image avec un flou gaussien
func traitement_bande_Gaussien(noyau [taille][taille]float64, borne_sup int, borne_inf int, bounds image.Rectangle, imageI image.Image, imageF *image.RGBA, wg *sync.WaitGroup) {
	/*
		Entrées :
			borne_sup, borne_inf : bornes des lignes de l'image à modifier dans cette goroutine
			bounds : bornes de l'image entière
			imageI : image source dont on veut obtenir l'image filtré
			imageF : image qui sera modifié lors de la fonction, de la même taille que imageI
		Sorties :
			None
	*/
	defer wg.Done()
	// Code du traitement et du filtre de l'image
	taille := len(noyau)
	// Pour tous les pixels sauf les bords
	for y := borne_inf; y < borne_sup; y++ {
		if bounds.Min.Y+taille < y && bounds.Max.Y-taille > y {
			for x := bounds.Min.X; x < bounds.Max.X; x++ {
				if bounds.Min.X+taille < x && bounds.Max.X-taille > x {
					R := 0.0
					G := 0.0
					B := 0.0
					// Pour tous les voisins dans le noyau :
					for i := 0; i < taille; i++ {
						for j := 0; j < taille; j++ {
							// Si on est pas sur le centre :
							if i != taille && j != taille {
								// Récupération de la couleur initial du pixel dans l'image initiale, et calcul du flou
								r, g, b, _ := imageI.At(x, y).RGBA()
								R += float64(r) * noyau[i][j]
								G += float64(g) * noyau[i][j]
								B += float64(b) * noyau[i][j]
							}
						}
					}
					// Conversion en 8 bits (0–255)
					R8 := uint8(R)
					G8 := uint8(G)
					B8 := uint8(B)
					a8 := uint8(255)

					couleur := color.RGBA{R8, G8, B8, a8}
					// Modification de la couleur du pixel sur l'image final par la couleur filtré
					imageF.Set(x, y, couleur)
				}
			}
		}
	}
}

// Definition de la fonction traitant une certaine bande d'image et crée la bande filtrée en noir et blanc
func traitement_bande_NoirBlanc(borne_sup int, borne_inf int, bounds image.Rectangle, imageI image.Image, imageF *image.RGBA, wg *sync.WaitGroup) {
	/*
		Entrées :
			borne_sup, borne_inf : bornes des lignes de l'image à modifier dans cette goroutine
			bounds : bornes de l'image entière
			imageI : image source dont on veut obtenir l'image filtré
			imageF : image qui sera modifié lors de la fonction, de la même taille que imageI
		Sorties :
			None
	*/
	defer wg.Done()
	// Code du traitement et du filtre de l'image
	// Pour tous les pixels
	for y := borne_inf; y < borne_sup; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			// Récupération de la couleur initial du pixel dans l'image initial
			// RGBA() retourne des valeurs sur 16 bits (0–65535)
			r, g, b, a := imageI.At(x, y).RGBA()

			// Obtention de la valeur filtré en gris sur 16 bit
			n := (r + g + b) / 3
			// Conversion en 8 bits (0–255)
			n8 := uint8(n >> 8)
			a8 := uint8(a >> 8)

			couleur := color.RGBA{n8, n8, n8, a8}
			// Modification de la couleur du pixel sur l'image final par la couleur filtré
			imageF.Set(x, y, couleur)
		}
	}
}

func main() {
	var wg sync.WaitGroup
	// Nombre de goroutines à utiliser
	n := 4
	wg.Add(n)

	var filtre int
	fmt.Print("Filtre 1 (n&b) ou 2(flou) ? :")
	fmt.Scan(&filtre)

	noyau := creation_matrice()
	// Import de l'image à partir du chemin
	file, err := os.Open("pomme.png")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	imageI, err := png.Decode(file)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Récupération des dimensions de l'image
	bounds := imageI.Bounds()

	// Création de la nouvelle image
	imageF := image.NewRGBA(image.Rect(bounds.Min.X, bounds.Min.Y, bounds.Max.X, bounds.Max.Y))

	// Calcul des bornes de la premier bande de l'image pour n bande et de l'intervale de chaque bande
	intervale := bounds.Max.Y / n
	b_inf := 0
	b_sup := intervale

	if filtre == 1 {
		// Pour chaque bande, lancer la go routine
		for i := 0; i < n; i++ {
			go traitement_bande_NoirBlanc(b_sup, b_inf, bounds, imageI, imageF, &wg)
			b_inf = b_inf + intervale
			if i != n-1 {
				b_sup = b_inf + intervale
			} else {
				b_sup = bounds.Max.Y
			}
		}
	}
	if filtre == 2 {
		// Pour chaque bande, lancer la go routine
		for i := 0; i < n; i++ {
			go traitement_bande_Gaussien(noyau, b_sup, b_inf, bounds, imageI, imageF, &wg)
			b_inf = b_inf + intervale
			if i != n-1 {
				b_sup = b_inf + intervale
			} else {
				b_sup = bounds.Max.Y
			}
		}

	}

	wg.Wait()

	// Finalisation de l'image
	file, erro := os.Create("output.png")
	if erro != nil {
		log.Fatalf("Error creating file: %v", err)
	}
	defer file.Close()

	if err := png.Encode(file, imageF); err != nil {
		log.Fatalf("Error encoding image: %v", err)
	}
}
