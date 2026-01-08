package main

// Imports :
import (
	"fmt"
	"net"
	"os"
)

// Constantes liées au serveur auquel on doit se connecter
const (
	HOST = "localhost"
	PORT = "8080"
	TYPE = "tcp"
)

func main() {
	//Cette fonction renvoie l'adresse du serveur TCP pour s'y connecter
	tcpServer, err := net.ResolveTCPAddr(TYPE, HOST+":"+PORT) 

	if err != nil {
		println("ResolveTCPAddr failed:", err.Error())
		os.Exit(1)
	}

	//Cette fonction permet de se connecter au serveur donné en paramètre
	conn, err := net.DialTCP(TYPE, nil, tcpServer) 
	if err != nil {
		println("Dial failed:", err.Error())
		os.Exit(1)
	}

	// Demande le chemin de l'image sur la machine
	var chemin string
	fmt.Print("Chemin de l'image : ")
	fmt.Scan(&chemin)

	// Demande le nom de la nouvelle image à créer
	var titre string
	fmt.Print("Titre de la nouvelle image (sans extension) : ")
	fmt.Scan(&titre)

	// Prépare le message à envoyer au serveur contenant les informations des noms d'image
	message := chemin + "," + titre + ".png"

	_, err = conn.Write([]byte(message))
	if err != nil {
		println("Write data failed:", err.Error())
		os.Exit(1)
	}

	// Buffer pour récolter les données
	received := make([]byte, 1024)
	_, err = conn.Read(received)
	if err != nil {
		println("Read data failed:", err.Error())
		os.Exit(1)
	}

	// Affiche le message de réponse renvoyé par le serveur rapportant sur l'execiton de la fonction
	println("Message reçu:", string(received))

	conn.Close()
}

