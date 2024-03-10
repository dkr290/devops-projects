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
// var (
// 	httpRequestsTotal = prometheus.NewCounterVec(
// 		prometheus.CounterOpts{
// 			Name: "http_requests_total",
// 			Help: "Total number of HTTP requests",
// 		},
// 		[]string{"method", "status"},
// 	)
// )

// func init(){
// 	prometheus.MustRegister(httpRequestsTotal)
// }

// Define routes
func (h *Handlers) GetHandler(c *gin.Context) {

	var kvkeys []KVKey

	kvkeys = []KVKey{
		{Secret: "secret1-v2", Metadata: "secret1-v2", Keyvault: "kv1-v2", Expireddate: "07/24/2016"},
	}

	// Create a PageData struct
	pageData := PageData{
		PageDataArray: kvkeys,
	}
     //httpRequestsTotal.WithLabelValues("GET", "200").Inc()
	// Render the HTML page with the PageData struct
	c.HTML(http.StatusOK, "index.html", gin.H{
		"PageData": pageData,
	})

}

