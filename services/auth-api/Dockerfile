# Build stage
FROM golang:1.18-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod init github.com/microservice-app/auth-api 2>/dev/null || true
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o auth-api .

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /app/auth-api .
EXPOSE 8080
CMD ["./auth-api"]
