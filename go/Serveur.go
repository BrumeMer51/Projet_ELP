package main

// Imports :
import (
	"image"
	"image/color"
	"image/png"
	"log"
	"math"
	"net"
	"os"
	"strings"
)

// Constantes liées à la socket utilisée par le serveur et à la taille de la matrice du flou gaussien :
const (
	HOST   = "localhost"
	PORT   = "7021"
	TYPE   = "tcp"
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

func filtreNoirBlanc(bounds image.Rectangle, imageI image.Image, imageF *image.RGBA) {
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
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

func filtreFlouGaussien(bounds image.Rectangle, imageI image.Image, imageF *image.RGBA, noyau [taille][taille]float64) {
	taille := len(noyau)
	// Pour tous les pixels sauf les bords
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
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

func traitement_image(chemin_image string, titre string, filtre string) {
	/*
		Fonction prenant en paramètre le chemin local vers une image, et créant une nouvelle image avec un filtre noir et blanc
		Entrées :

			chemin_image : string indiquant le chemin local vers une image
			titre : string donnant le nom de la nouvelle image

		Sorties :

			None
	*/
	// Import de l'image
	file, err := os.Open(chemin_image)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	imageI, err := png.Decode(file)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Récupération des dimensions
	bounds := imageI.Bounds()

	// Création de la nouvelle image
	imageF := image.NewRGBA(image.Rect(bounds.Min.X, bounds.Min.Y, bounds.Max.X, bounds.Max.Y))

	// Traitement de l'image
	if filtre == "1" {
		filtreNoirBlanc(bounds, imageI, imageF)
	} else {
		noyau := creation_matrice()
		filtreFlouGaussien(bounds, imageI, imageF, noyau)
	}

	// Finalisation de l'image
	file, erro := os.Create(titre)
	if erro != nil {
		log.Fatalf("Error creating file: %v", err)
	}
	defer file.Close()

	if err := png.Encode(file, imageF); err != nil {
		log.Fatalf("Error encoding image: %v", err)
	}
}

func handleRequest(conn net.Conn) {
	/*
		Fonction prenant en paramètre une sortie de pipe qui lit sur cette pipe et applique un filtre à l'image envoyée
		Entrées :

			conn : sortie d'une pipe

		Sorties :

			None
	*/
	// Décryptage de la requête entrante dans un buffer
	buffer := make([]byte, 1024)
	n, err := conn.Read(buffer)
	if err != nil {
		log.Fatal(err)
	}

	// Sélection de l'image à traiter, récupération du titre de la nouvelle image et traitement
	recu := string(buffer[:n])
	morceaux := strings.Split(recu, ",")

	if len(morceaux) == 3 {
		chemin := strings.TrimSpace(morceaux[0])
		titre := strings.TrimSpace(morceaux[1])
		filtre := strings.TrimSpace(morceaux[2])
		traitement_image(chemin, titre, filtre)

		responseStr := "Image traitée"
		conn.Write([]byte(responseStr))
	} else {
		conn.Write([]byte("Erreur : message mal formaté"))
	}
	// Fermeture de la connection
	conn.Close()
}

func main() {
	// Création du serveur
	listen, err := net.Listen(TYPE, HOST+":"+PORT)
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}
	// Lancement de l'écoute de manière infinie, quand une connexion est demandée de la part d'un client, une goroutine est lancée
	defer listen.Close() //La fermeture de l'écoute est différée au moment où le serveur sera fermé
	for {
		conn, err := listen.Accept()
		if err != nil {
			log.Fatal(err)
			os.Exit(1)
		}
		go handleRequest(conn)
	}
}
