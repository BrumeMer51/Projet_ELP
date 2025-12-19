package main

import (
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"log"
	"os"
)

func main() {
	//ouverture de l'image initiale
	file, err := os.Open("pomme.png")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	pomme, err := png.Decode(file)
	if err != nil {
		log.Fatal(err)
	}
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}
	bounds := pomme.Bounds()

	//création de la nouvelle image
	bis := image.NewRGBA(image.Rect(bounds.Min.X, bounds.Min.Y, bounds.Max.X, bounds.Max.Y))

	//tentative d'ajout de couleur à la nouvelle image
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			r, g, b, a := pomme.At(x, y).RGBA()

			// RGBA() retourne des valeurs sur 16 bits (0–65535)
			// Conversion en 8 bits (0–255)
			r8 := uint8(r >> 8)
			g8 := uint8(g >> 8)
			b8 := uint8(b >> 8)
			a8 := uint8(a >> 8)

			n := (r + g + b) / 3
			n8 := uint8(n >> 8)

			couleur := color.RGBA{n8, n8, n8, a8}
			bis.Set(x, y, couleur)

			//parce qu'il faut utiliser les variables
			if a8 == 0 {
				fmt.Printf("r8 = %d, g8 = %d, b8 = %d", r8, g8, b8)
			}
		}
	}

	file, erro := os.Create("output.png")
	if erro != nil {
		log.Fatalf("Error creating file: %v", err)
	}
	defer file.Close()

	if err := png.Encode(file, bis); err != nil {
		log.Fatalf("Error encoding image: %v", err)
	}

}

func addImage(baseImage *image.RGBA, path string, point image.Point) error {
	fichier, err := os.Open(path)
	if err != nil {
		return err
	}

	template, _, err := image.Decode(fichier)

	if err != nil {
		return err
	}

	draw.Draw(baseImage, baseImage.Bounds(), template, point, draw.Over)

	return nil
}
