package main

import (
	"currentcy-converter/handlers"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
)

func main() {
	apiKey, apiHost, url := getEnv()

	router := chi.NewMux()

	// Handle static files
	router.Handle("/static/*", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	handlers.GetApiParams(apiKey, apiHost, url)

	router.Get("/", handlers.MakeHandler(handlers.ServeTemplate))
	router.Get("/convert", handlers.MakeHandler(handlers.GetCurrencyValueHandler))

	port := ":5555"
	fmt.Printf("Server running on port %s...\n", port)
	log.Fatal(http.ListenAndServe(port, router))

}
func getEnv() (string, string, string) {

	apiKey := os.Getenv("APIKEY")
	if len(apiKey) == 0 {
		log.Fatal("Please add APIKEY variable")

	}
	apiHost := os.Getenv("APIHOST")
	if len(apiHost) == 0 {
		log.Fatal("Please add APIHOST varialbe")
	}
	url := "https://" + apiHost + "/convert"

	return apiKey, apiHost, url
}
