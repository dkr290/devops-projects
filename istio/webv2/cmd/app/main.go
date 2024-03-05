package main

import (
	"html/template"

	"github.com/dkr290/go-projects/webs-test/webv1/handlers"
	"github.com/gin-gonic/gin"
)

func main() {

	//initialize gin
	r := gin.Default()
	//get database type to be able to use methods related to redis

	// passing the redis cache to the handlers
	hand := handlers.NewHandlers(r)

	// Load HTML template
	r.SetHTMLTemplate(template.Must(template.ParseFiles("templates/index.html")))
	r.GET("/", hand.GetHandler)

	// Run the server
	r.Run(":8080")

}
