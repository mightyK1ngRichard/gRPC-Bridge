# Используем Go 1.22 для сборки проекта
FROM golang:1.22-alpine AS builder

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем Go модули и загружаем зависимости
COPY go.mod go.sum ./
RUN go mod download

# Копируем весь проект в контейнер
COPY . .

# Собираем приложение
RUN go build -o /grpc-server ./cmd/server/main.go

# Указываем минимальный базовый образ для конечного контейнера
FROM alpine:latest

# Создаем директорию для приложения
WORKDIR /root/

# Копируем скомпилированный сервер из предыдущего этапа
COPY --from=builder /grpc-server .

# Указываем команду для запуска приложения
CMD ["./grpc-server"]

# Открываем порт для gRPC
EXPOSE 50051