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

func TestParseTMMountPoint(t *testing.T) {
	tests := []struct {
		stdout string
		want   string
		err    error
	}{
		{
			stdout: `====================================================
Name          : TM
Kind          : Local
ID            : AAAAAAAA-XXXX-4FB1-XXXX-XXXXXXXXXXXX`,
			want: "",
			err:  ErrNotFound,
		},
		{
			stdout: `====================================================
Name          : TM
Kind          : Local
Mount Point   : /Volumes/TM
ID            : AAAAAAAA-XXXX-XXXX-XXXX-XXXXXXXXXXXX`,
			want: "/Volumes/TM",
		},
		{
			stdout: `====================================================
Name          : TM With Spaces
Kind          : Local
Mount Point   : /Volumes/TM With Spaces
ID            : AAAAAAAA-XXXX-XXXX-XXXX-XXXXXXXXXXXX`,
			want: "/Volumes/TM With Spaces",
		},
	}

	for i, test := range tests {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			value, err := parseTMMountPoint(test.stdout)
			assert.Equal(t, test.err, err)
			assert.Equal(t, test.want, value)
		})
	}
}
