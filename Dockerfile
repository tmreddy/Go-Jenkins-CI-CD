# ---- Build Stage ----
FROM golang:1.24.3 AS builder

WORKDIR /app

# Download dependencies first (better caching)
COPY go.mod  ./
RUN go mod download

# Copy source
COPY . .

# Build the Go app as a static binary for Linux amd64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o go-jenkins-ci-cd main.go


# ✅ Run unit tests here
RUN go test ./...


# ---- Runtime Stage ----
FROM debian:bullseye-slim

WORKDIR /app

# Copy compiled binary
COPY --from=builder /app/go-jenkins-ci-cd .

# Run app on container start
CMD ["./go-jenkins-ci-cd"]
