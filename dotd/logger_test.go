package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetLogger(t *testing.T) {
	// test no error
	logger, err := getLogger()
	assert.Nil(t, err)
	assert.NotNil(t, logger)
}
