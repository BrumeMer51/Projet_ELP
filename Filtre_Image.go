package main

import (
	"image"
	"image/color"
	"image/png"
	"log"
	"os"
	"sync"
)

// Definition de la fonction traitant une certaine bande d'image et renvoyant la bande filtrée
func traitement_bande(borne_sup int, borne_inf int, bounds image.Rectangle, imageI image.Image, imageF *image.RGBA, wg *sync.WaitGroup) {
	defer wg.Done()
	// Code traitement image
	for y := borne_inf; y < borne_sup; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			r, g, b, a := imageI.At(x, y).RGBA()
			n := (r + g + b) / 3

			// RGBA() retourne des valeurs sur 16 bits (0–65535)
			// Conversion en 8 bits (0–255)
			n8 := uint8(n >> 8)
			a8 := uint8(a >> 8)

			couleur := color.RGBA{n8, n8, n8, a8}
			imageF.Set(x, y, couleur)

		}
	}
}

func main() {
	var wg sync.WaitGroup
	n := 4
	// Import de l'image
	file, err := os.Open("deepfield.png")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	imageI, err := png.Decode(file)
	if err != nil {
		log.Fatal(err)
	}
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Récupération des dimensions
	bounds := imageI.Bounds()

	// Création de la nouvelle image
	imageF := image.NewRGBA(image.Rect(bounds.Min.X, bounds.Min.Y, bounds.Max.X, bounds.Max.Y))

	// Division de l'image en n bande
	intervale := bounds.Max.Y / n
	b_inf := 0
	b_sup := 0

	// Pour chaque bande lancer la go routine
	for i := 0; i < n; i++ {
		b_inf = b_inf + intervale
		if i != n-1 {
			b_sup = b_inf + intervale
		} else {
			b_sup = bounds.Max.Y
		}

		go traitement_bande(b_sup, b_inf, bounds, imageI, imageF, &wg)
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



