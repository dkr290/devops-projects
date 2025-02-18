package main

import (
	"bufio"
	"fmt"
	"os"

	"golang.org/x/crypto/bcrypt"
)

var hashCost int = 12

func main() {
	fmt.Println("OpenSearch Password Hasher")
	fmt.Print("Enter password to hash: ")

	// Read password input from the user
	reader := bufio.NewReader(os.Stdin)
	password, err := reader.ReadString('\n')
	if err != nil {
		fmt.Println("Error reading password:", err)
		return
	}

	// Remove the newline character from the input
	password = password[:len(password)-1]

	// Hash the password using bcrypt with a cost of 12
	hash, err := bcrypt.GenerateFromPassword([]byte(password), hashCost)
	if err != nil {
		fmt.Println("Error hashing password:", err)
		return
	}

	// Print the resulting hash
	fmt.Println("Generated hash:")
	fmt.Println(string(hash))
}
