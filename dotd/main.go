package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"go.uber.org/zap"
)

var (
	PORT = "2315"
	ADDR = ":" + PORT
)

func main() {
	logger, _ := getLogger()

	mux := http.NewServeMux()
	mux.HandleFunc("/ping", accessGuard(logger, ping))
	mux.HandleFunc("/disks/eject", accessGuard(logger, ejectDisks(logger)))

	server := http.Server{
		Addr:         ADDR,
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		logger.Sugar().Infow("starting server", "port", PORT)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("listen and serve returned err: %v", err)
		}
		logger.Sugar().Infow("server started", "port", PORT)
	}()

	<-ctx.Done()
	logger.Info("got interruption signal, shutting down server")
	if err := server.Shutdown(context.TODO()); err != nil {
		logger.Error("server shutdown failed", zap.Error(err))
	}

	logger.Info("server shutdown successfully")
}
