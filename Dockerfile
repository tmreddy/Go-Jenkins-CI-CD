# ---- Build Stage ----
FROM golang:1.24.3 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# ✅ Run unit tests here
RUN go test ./...

# Build the Go app
RUN go build -o go-jenkins-webhook

# ---- Runtime Stage ----
FROM debian:bullseye-slim

WORKDIR /app

COPY --from=builder /app/go-jenkins-webhook .

CMD ["./go-jenkins-webhook"]
