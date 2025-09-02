# ---- Build Stage ----
FROM golang:1.24.3 AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o go-jenkins-webhook .

# ✅ Run unit tests here
RUN go test ./...

# Build the Go app
RUN go build -o go-jenkins-webhook

# ---- Runtime Stage ----
FROM debian:bullseye-slim

WORKDIR /app

COPY --from=builder /app/go-jenkins-webhook .

CMD ["./go-jenkins-webhook"]
