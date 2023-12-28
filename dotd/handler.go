package main

import (
	"net/http"

	"go.uber.org/zap"
)

// ping returns a pong message
func ping(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	_, _ = w.Write([]byte("pong\n"))
}

// ejectDisks ejects all external disks
func ejectDisks(logger *zap.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		logger.Info("request received", zap.String("path", r.URL.Path))

		running, err := isTMRunning()
		if err != nil {
			logger.Error("failed to check if TM is running", zap.Error(err))
			fail(w)
			return
		}
		if running {
			if err = stopTMBackup(); err != nil {
				logger.Error("failed to stop TM backup", zap.Error(err))
				fail(w)
				return
			}

			for {
				running, err = isTMRunning()
				if err != nil {
					logger.Error("failed to check if TM is running", zap.Error(err))
					fail(w)
					return
				}
				if !running {
					break
				}
			}
		}
		mountPath, err := getTMMountPoint()
		logger.Info("found mount path", zap.String("mountPath", mountPath))
		if err != nil {
			logger.Error("failed to get TM mount point", zap.Error(err))
			fail(w)
			return
		}
		if mountPath != "" {
			if err := ejectDisk(logger, mountPath); err != nil {
				logger.Error("failed to eject disk", zap.Error(err))
				fail(w)
				return
			}
		}

		success(w)
	}
}
