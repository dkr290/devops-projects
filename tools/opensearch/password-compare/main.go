package main

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

var (
	hashedString string
	testPlain    string
)

func main() {
	// Stored hashed password (from internal_users.yml)
	hashedPassword := []byte(hashedString)

	// Test password you want to verify
	testPassword := []byte(testPlain) // Replace with the actual password to test

	// Compare the hashed password with the test password
	err := bcrypt.CompareHashAndPassword(hashedPassword, testPassword)
	if err != nil {
		fmt.Println("Password does not match!")
	} else {
		fmt.Println("Password matches!")
	}
}
