package main

// Imports :
import (
	"image"
	"image/color"
	"image/png"
	"log"
	"net"
	"os"
	"strings"
)

// Constantes liées à la socket utilisée par le serveur :
const (
	HOST = "localhost"
	PORT = "8080"
	TYPE = "tcp"
)

func traitement_image(chemin_image string) {
	/*
		Fonction prenant en paramètre le chemin local vers une image, et créant une nouvelle image avec un filtre noir et blanc
		Entrées :

			chemin_image : string

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
		log.Fatal(err)
	}
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Récupération des dimensions
	bounds := imageI.Bounds()

	// Création de la nouvelle image
	imageF := image.NewRGBA(image.Rect(bounds.Min.X, bounds.Min.Y, bounds.Max.X, bounds.Max.Y))

	// Traitement de l'image
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

	// Finalisation de l'image
	file, erro := os.Create("Resultat.png")
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

			conn : net.Conn

		Sorties :

			None
	*/
	// Décryptage de la requête entrante dans un buffer
	buffer := make([]byte, 1024)
	n, err := conn.Read(buffer)
	if err != nil {
		log.Fatal(err)
	}

	// Sélection de l'image et traitement
	chemin := string(buffer[:n])
	chemin = strings.TrimSpace(chemin)
	traitement_image(chemin)

	responseStr := "Image traitée"
	conn.Write([]byte(responseStr))
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
