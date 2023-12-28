package main

import "go.uber.org/zap"

func getLogger() (*zap.Logger, error) {
	logger, err := zap.NewProduction()
	return logger, err
}
