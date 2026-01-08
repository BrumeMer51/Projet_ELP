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
	tcpServer, err := net.ResolveTCPAddr(TYPE, HOST+":"+PORT) //Cette fonction renvoie l'adresse du serveur TCP pour s'y connecter

	if err != nil {
		println("ResolveTCPAddr failed:", err.Error())
		os.Exit(1)
	}

	conn, err := net.DialTCP(TYPE, nil, tcpServer) //Cette fonction permet de se connecter au serveur donné en paramètre
	if err != nil {
		println("Dial failed:", err.Error())
		os.Exit(1)
	}

	var chemin string
	fmt.Print("Chemin de l'image : ")
	fmt.Scan(&chemin)

	_, err = conn.Write([]byte(chemin))
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

	println("Message reçu:", string(received))

	conn.Close()
}
