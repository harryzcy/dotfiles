package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestStatus(t *testing.T) {
	tests := []struct {
		status  string
		code    int
		handler func(w http.ResponseWriter)
	}{
		{
			status:  "success",
			code:    http.StatusOK,
			handler: success,
		},
		{
			status:  "error",
			code:    http.StatusInternalServerError,
			handler: fail,
		},
	}

	for _, test := range tests {
		w := httptest.NewRecorder()
		test.handler(w)

		assert.Equal(t, test.code, w.Code)

		var resp map[string]string
		err := json.Unmarshal(w.Body.Bytes(), &resp)
		assert.Nil(t, err)
		assert.Equal(t, test.status, resp["status"])
	}
}
