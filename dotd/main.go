package main

import (
	"fmt"
	"net/http"
)

const (
	ADDR = ":2315"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/ping", ping)
	mux.HandleFunc("/disks/eject", ejectDisks)

	server := http.Server{
		Addr:    ADDR,
		Handler: mux,
	}

	fmt.Println("Listening on " + ADDR)
	server.ListenAndServe()
}
