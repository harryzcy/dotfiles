package main

import (
	"bytes"
	"errors"
	"os/exec"
	"strings"
)

var (
	ErrMalformedContent = errors.New("malformed content")
	ErrUnexpectedValue  = errors.New("unexpected value")
	ErrNotFound         = errors.New("not found")
	ErrMountPathEmpty   = errors.New("mount path is empty")
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
			parts := strings.Split(trimmed, "=")
			if len(parts) != 2 {
				return nil, ErrMalformedContent
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

func getTMMountPoint() (string, error) {
	output, err := runCommand("tmutil", "destinationinfo")
	if err != nil {
		return "", err
	}

	return parseTMMountPoint(string(output.stdout))
}

func parseTMMountPoint(stdout string) (string, error) {
	for _, line := range strings.Split(stdout, "\n") {
		if strings.Contains(line, "Mount Point") {
			parts := strings.Split(line, ":")
			if len(parts) != 2 {
				return "", ErrMalformedContent
			}
			mountPath := strings.TrimSpace(parts[1])
			return mountPath, nil
		}
	}

	return "", ErrNotFound
}

func ejectDisk(mountPath string) error {
	if mountPath == "" {
		return ErrMountPathEmpty
	}
	_, err := runCommand("diskutil", "eject", mountPath)
	return err
}
