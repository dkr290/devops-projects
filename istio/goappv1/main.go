package main

import (
	"log"
	"net/http"
	"os"

	"github.com/dkr290/devops-projects/istio/goappv1/handlers"
)

func main() {

	message := handlers.NewHandler("Istio form golang app.", "v1")

	http.HandleFunc("/", message.IndexHandler)
	http.HandleFunc("/app/message", message.MessageHandler)
	http.HandleFunc("/app/v1/message", message.MessageHandler)

	log.Println("Starting the server")
	http.ListenAndServe(port(), nil)
}

func port() string {
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}
	return ":" + port
}
