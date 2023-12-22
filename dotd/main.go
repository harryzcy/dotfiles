package main

import (
	"fmt"
	"net/http"
	"time"
)

const (
	ADDR = ":2315"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/ping", ping)
	mux.HandleFunc("/disks/eject", ejectDisks)

	server := http.Server{
		Addr:         ADDR,
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
	}

	fmt.Println("Listening on " + ADDR)

	server.ListenAndServe()
}
