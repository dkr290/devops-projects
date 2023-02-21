package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type Message struct {
	Message string
	Version string
}

func NewHandler(m string, version string) *Message {
	return &Message{
		Message: m,
		Version: version,
	}
}

func (m *Message) MessageHandler(w http.ResponseWriter, r *http.Request) {

	b, err := json.Marshal(m)

	if err != nil {
		panic(err)
	}

	w.Header().Add("Content-Type", "application/json; charset=utf-8")
	w.Write(b)
}

func (m *Message) IndexHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Welcome to golang app version 1")
}
