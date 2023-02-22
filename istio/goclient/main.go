package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
)

type Page struct {
	Message string `json:"message"`
	Version string `json:"version"`
	Error   error
}

var (
	requestURL string
	parsedURL  *url.URL
	err        error
)

func main() {
	flag.StringVar(&requestURL, "url", "", "url to access")

	flag.Parse()

	if parsedURL, err = url.ParseRequestURI(requestURL); err != nil {
		fmt.Printf("Validation error: URL is not valid: %s", err)
		flag.Usage()
		os.Exit(1)
	}

	res, err := doRequest(parsedURL.String())

	if err.Err != nil {
		if !strings.Contains(err.Body, "Welcome to golang app version") {
			fmt.Printf("Error: %s (HTTP code: %d, Body:%s\n", err.Err, err.HTTPCode, err.Body)
			os.Exit(1)
		} else {
			fmt.Printf("Message: %s", err.Body)
			return
		}
	}

	fmt.Printf("Message: %s\n", res.Message)
	fmt.Printf("Version: %s", res.Version)

}

func doRequest(requestURL string) (Page, RequestError) {

	if _, err := url.ParseRequestURI(requestURL); err != nil {
		return Page{Error: nil}, RequestError{

			Err: fmt.Errorf("vaidation error, url is not valid: %s", err),
		}
	}

	response, err := http.Get(requestURL)

	if err != nil {
		return Page{Error: nil}, RequestError{
			HTTPCode: response.StatusCode,
			Err:      fmt.Errorf("http Get error: %s", err),
		}

	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)

	if err != nil {
		return Page{Error: nil}, RequestError{
			HTTPCode: response.StatusCode,
			Body:     string(body),
			Err:      fmt.Errorf("ReadAll error: %s", err),
		}
	}

	if response.StatusCode != 200 {

		return Page{Error: nil}, RequestError{
			HTTPCode: response.StatusCode,
			Body:     string(body),
			Err:      fmt.Errorf("invalid output (HTTP Code %d): %s", response.StatusCode, string(body)),
		}

	}

	if !json.Valid(body) {
		return Page{Error: nil}, RequestError{
			HTTPCode: response.StatusCode,
			Body:     string(body),
			Err:      fmt.Errorf("no valid JSON returned"),
		}

	}

	var page Page
	err = json.Unmarshal(body, &page)
	if err != nil {
		return Page{Error: nil}, RequestError{
			HTTPCode: response.StatusCode,
			Body:     string(body),
			Err:      fmt.Errorf("Page Unmarshal error %s", err),
		}
	}

	return page, RequestError{Err: nil}
}
