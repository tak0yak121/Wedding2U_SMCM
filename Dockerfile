FROM alpine:latest
WORKDIR /app
COPY . .
CMD ["echo", "Wedding2U Docker image built successfully"]