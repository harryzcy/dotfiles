package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPing(t *testing.T) {
	w := httptest.NewRecorder()
	r := httptest.NewRequest("GET", "/ping", nil)
	ping(w, r)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Equal(t, "pong\n", w.Body.String())
	assert.Equal(t, "text/plain", w.Header().Get("Content-Type"))
}
