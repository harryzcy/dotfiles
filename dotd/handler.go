package main

import (
	"fmt"
	"net/http"
)

// ping returns a pong message
func ping(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("pong\n"))
}

// ejectDisks ejects all external disks
func ejectDisks(w http.ResponseWriter, r *http.Request) {
	running, err := isTMRunning()
	if err != nil {
		fmt.Println(err)
		fail(w)
		return
	}
	if running {
		if err = stopTMBackup(); err != nil {
			fmt.Println(err)
			fail(w)
			return
		}
	}

	success(w)
}

func success(w http.ResponseWriter) {
	w.Write([]byte("{\"status\":\"success\"}"))
}

func fail(w http.ResponseWriter) {
	w.Write([]byte("{\"status\":\"error\"}"))
}
