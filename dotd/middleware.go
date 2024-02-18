package main

import (
	"net"
	"net/http"

	"go.uber.org/zap"
)

var privateIPNetworks = []net.IPNet{
	{
		IP:   net.ParseIP("10.0.0.0"),
		Mask: net.CIDRMask(8, 32),
	},
	{
		IP:   net.ParseIP("172.16.0.0"),
		Mask: net.CIDRMask(12, 32),
	},
	{
		IP:   net.ParseIP("192.168.0.0"),
		Mask: net.CIDRMask(16, 32),
	},
	{
		IP:   net.ParseIP("127.0.0.1"),
		Mask: net.CIDRMask(8, 32),
	},
	{
		IP:   net.ParseIP("::1"),
		Mask: net.CIDRMask(128, 128),
	},
}

func isPrivate(ip net.IP) bool {
	for _, ipNet := range privateIPNetworks {
		if ipNet.Contains(ip) {
			return true
		}
	}
	return false
}

// accessGuard is a middleware that checks if the request is authorized
func accessGuard(logger *zap.Logger, fn http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		logger.Info("request received",
			zap.String("path", r.URL.Path),
			zap.String("remoteAddr", r.RemoteAddr),
		)

		// check if the request is authorized
		// if not, return http.StatusUnauthorized
		// otherwise, call fn(w, r)
		ipStr, _, err := net.SplitHostPort(r.RemoteAddr)
		if err != nil {
			logger.Error("failed to split remote address", zap.Error(err))
			fail(w)
			return
		}
		ip := net.ParseIP(ipStr)
		if ip == nil {
			logger.Error("failed to parse remote address", zap.String("remoteAddr", r.RemoteAddr))
			fail(w)
			return
		}
		if !isPrivate(ip) {
			logger.Error("request from non-private IP", zap.String("remoteAddr", r.RemoteAddr))
			fail(w)
			return
		}

		fn(w, r)
	}
}

func success(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	_, err := w.Write([]byte("{\"status\":\"success\"}"))
	if err != nil {
		http.Error(w, "failed to write response", http.StatusInternalServerError)
	}
}

func fail(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusInternalServerError)
	_, err := w.Write([]byte("{\"status\":\"error\"}"))
	if err != nil {
		http.Error(w, "failed to write response", http.StatusInternalServerError)
	}
}
