package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHelloHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "http://localhost:8080/", nil)
	w := httptest.NewRecorder()

	helloHandler(w, req)

	resp := w.Result()
	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status 200, got %d", resp.StatusCode)
	}

	body := w.Body.String()
	if body != "Hello, World!" {
		t.Errorf("expected body 'Hello, World!', got '%s'", body)
	}
}

func TestHelloJenkinsHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "http://localhost:8080/jenkins", nil)
	w := httptest.NewRecorder()

	helloJenkinsHandler(w, req)

	resp := w.Result()
	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status 200, got %d", resp.StatusCode)
	}

	body := w.Body.String()
	if body != "Hello, Jenkins!" {
		t.Errorf("expected body 'Hello, Jenkins!', got '%s'", body)
	}
}

func TestHealthCheckHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "http://localhost:8080/health", nil)
	w := httptest.NewRecorder()

	healthCheckHandler(w, req)

	resp := w.Result()
	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status 200, got %d", resp.StatusCode)
	}

	body := w.Body.String()
	if body != "OK" {
		t.Errorf("expected body 'OK', got '%s'", body)
	}
}
