package main

type RequestError struct {
	HTTPCode int
	Body     string
	Err      error
}

func (r RequestError) Error() string {

	return r.Error()
}
