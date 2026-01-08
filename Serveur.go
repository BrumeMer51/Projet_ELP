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

func traitement_image(chemin_image string, titre string) {
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

	// Récupération des dimensions de l'image
	bounds := imageI.Bounds()

	// Création de la nouvelle image
	imageF := image.NewRGBA(image.Rect(bounds.Min.X, bounds.Min.Y, bounds.Max.X, bounds.Max.Y))

	// Traitement de l'image
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
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
	chemin, titre, ok := strings.Cut(recu, ",")

	chemin = strings.TrimSpace(chemin)

	if ok == true {
		traitement_image(chemin, titre)

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
	// Lancement de l'écoute de manière infinie, quand une connexion est demandée de la part d'un client, une go routine est lancée
	// La fermeture de l'écoute est différée au moment où le serveur sera fermé
	defer listen.Close() 
	for {
		conn, err := listen.Accept()
		if err != nil {
			log.Fatal(err)
			os.Exit(1)
		}
		go handleRequest(conn)
	}
}

