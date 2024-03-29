package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// PageData represents the data structure for the HTML template
type KVKey struct {
	Secret      string `json:"secret" redis:"secret"`
	Metadata    string `json:"metadata" redis:"metadata"`
	Keyvault    string `json:"keyvault" redis:"keyvault"`
	Expireddate string `json:"expireddate" redis:"expireddate"`
}

type PageData struct {
	PageDataArray []KVKey
}

type Handlers struct {
	r *gin.Engine
}

func NewHandlers(r *gin.Engine) *Handlers {
	return &Handlers{
		r: r,
	}
}

// Define routes
func (h *Handlers) GetHandler(c *gin.Context) {

	var kvkeys []KVKey

	kvkeys = []KVKey{
		{Secret: "secret1-v1", Metadata: "secret1-v1", Keyvault: "kv1-v1", Expireddate: "07/05/2010"},
	}

	// Create a PageData struct
	pageData := PageData{
		PageDataArray: kvkeys,
	}

	// Render the HTML page with the PageData struct
	c.HTML(http.StatusOK, "index.html", gin.H{
		"PageData": pageData,
	})

}
