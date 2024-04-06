package handlers

import (
	"encoding/json"
	"fmt"
	"html/template"
	"net/http"
	"path/filepath"
)

var (
	apiKey  string
	apiHost string
	apiUrl  string
)

func GetApiParams(apikey, apihost, url string) {
	apiKey = apikey
	apiHost = apihost
	apiUrl = url
}

func ServeTemplate(w http.ResponseWriter, r *http.Request) error {
	lp := filepath.Join("templates", "index.html")

	tmpl, err := template.ParseFiles(lp)
	if err != nil {
		return err
	}
	tmpl.Execute(w, nil)
	return nil
}

func GetCurrencyValueHandler(w http.ResponseWriter, r *http.Request) error {
	sourceCurrency := r.URL.Query().Get("from")
	if sourceCurrency == "" {
		sourceCurrency = "USD"
	}
	targetCurrency := r.URL.Query().Get("to")
	if targetCurrency == "" {
		targetCurrency = "USD"
	}
	amount := r.URL.Query().Get("amount")
	if amount == "" {
		amount = "1"
	}

	queryParams := fmt.Sprintf("?from=%s&to=%s&amount=%s", sourceCurrency, targetCurrency, amount)
	req, err := http.NewRequest("GET", apiUrl+queryParams, nil)
	if err != nil {
		return err
	}

	req.Header.Set("X-RapidAPI-Key", apiKey)
	req.Header.Set("X-RapidAPI-Host", apiHost)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	var result interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return err
	}

	// Serve JSON response
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)

	return nil
}
