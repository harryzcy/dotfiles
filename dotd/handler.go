package main

import (
	"fmt"
	"net/http"
)

// ping returns a pong message
func ping(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	_, _ = w.Write([]byte("pong\n"))
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
			fail(w)
			return
		}

		for {
			running, err = isTMRunning()
			if err != nil {
				fail(w)
				return
			}
			if !running {
				break
			}
		}
	}
	mountPath, err := getTMMountPoint()
	if err != nil {
		fail(w)
		return
	}
	if mountPath != "" {
		if err := ejectDisk(mountPath); err != nil {
			fail(w)
			return
		}
	}

	success(w)
}

func success(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	_, _ = w.Write([]byte("{\"status\":\"success\"}"))
}

func fail(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusInternalServerError)
	_, _ = w.Write([]byte("{\"status\":\"error\"}"))
}
