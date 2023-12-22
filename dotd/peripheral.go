package main

import (
	"bytes"
	"errors"
	"os/exec"
	"strings"
)

var (
	ErrMalformedPlist  = errors.New("malformed plist content")
	ErrUnexpectedValue = errors.New("unexpected value")
	ErrNotFound        = errors.New("not found")
)

type commandOutput struct {
	stdout []byte
	stderr []byte
}

func runCommand(name string, args ...string) (*commandOutput, error) {
	stdout := &bytes.Buffer{}
	stderr := &bytes.Buffer{}
	cmd := exec.Command(name, args...)
	cmd.Stdout = stdout
	cmd.Stderr = stderr
	err := cmd.Run()
	if err != nil {
		return nil, err
	}

	return &commandOutput{
		stdout: stdout.Bytes(),
		stderr: stderr.Bytes(),
	}, nil
}

func getPlistField(content, field string) (interface{}, error) {
	inBlock := false
	for _, line := range strings.Split(content, "\n") {
		line = strings.TrimSpace(line)
		if line == "{" {
			inBlock = true
			continue
		} else if line == "}" {
			inBlock = false
		}

		if inBlock {
			trimmed := strings.TrimRight(line, ";")
			parts := strings.SplitN(trimmed, "=", 2)
			if len(parts) != 2 {
				return nil, ErrMalformedPlist
			}
			if strings.TrimSpace(parts[0]) != field {
				continue
			}

			value := strings.TrimSpace(parts[1])

			// string
			if strings.HasPrefix(value, "\"") && strings.HasSuffix(value, "\"") {
				return value[1 : len(value)-2], nil
			}
			return value, nil
		}
	}

	return nil, ErrNotFound
}

func isTMRunning() (bool, error) {
	output, err := runCommand("tmutil", "status")
	if err != nil {
		return false, err
	}

	value, err := getPlistField(string(output.stdout), "Running")
	if err != nil {
		return false, err
	}
	if value == "1" {
		return true, nil
	}
	if value == "0" {
		return false, nil
	}
	return false, ErrUnexpectedValue
}

func stopTMBackup() error {
	_, err := runCommand("tmutil", "stopbackup")
	return err
}
