package main

import (
	"image"
	"image/color"
	"image/png"
	"log"
	"os"
	"sync"
)

// Definition de la fonction traitant une certaine bande d'image et crée la bande filtrée
func traitement_bande(borne_sup int, borne_inf int, bounds image.Rectangle, imageI image.Image, imageF *image.RGBA, wg *sync.WaitGroup) {
	/*
		entrées :
			borne_sup, borne_inf : bornes des lignes de l'image à modifier dans cette goroutine
			bounds : bornes de l'image entière
			imageI : image source dont on veut obtenir l'image filtré
			imageF : image qui sera modifié lors de la fonction, de la même taille que imageI
		sorties :
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
	// nombre de goroutines à utilisé
	n := 4
	// Import de l'image à partir du chemin
	file, err := os.Open("deepfield.png")
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

	// Pour chaque bande lancer la go routine
	for i := 0; i < n; i++ {
		go traitement_bande(b_sup, b_inf, bounds, imageI, imageF, &wg)
		b_inf = b_inf + intervale
		if i != n-1 {
			b_sup = b_inf + intervale
		} else {
			b_sup = bounds.Max.Y
		}
	}

	wg.Wait()

	// Finalisation de l'image
	file, erro := os.Create("output_big_2.png")
	if erro != nil {
		log.Fatalf("Error creating file: %v", err)
	}
	defer file.Close()

	if err := png.Encode(file, imageF); err != nil {
		log.Fatalf("Error encoding image: %v", err)
	}
}
