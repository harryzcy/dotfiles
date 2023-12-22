package main

import (
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetPlistField(t *testing.T) {
	tests := []struct {
		content string
		field   string
		want    interface{}
		err     error
	}{
		{
			content: `Backup session status:
{
		ClientID = "com.apple.backupd";
		Percent = "-1";
		Running = 0;
}`,
			field: "Running",
			want:  "0",
		},
	}

	for i, test := range tests {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			value, err := getPlistField(test.content, test.field)
			assert.Equal(t, test.err, err)
			assert.Equal(t, test.want, value)
		})
	}
}
