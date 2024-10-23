# Swift+Go+gRPC

## Quick start

Запуск gRPC сервиса (Запускать в папке gRPC-Service):
```go
make start
```

## gRPC Сервис:

Генерация прото файла для калькулятора
```bash
protoc -I proto proto/calc.proto --go_out=./internal/pkg/calc/generated/ \
 --go_opt=paths=source_relative --go-grpc_out=./internal/pkg/calc/generated/ \
 --go-grpc_opt=paths=source_relative
```

Генерация прото файла для чата
```bash
protoc -I proto proto/chat.proto --go_out=./internal/pkg/chat/generated/ \
 --go_opt=paths=source_relative --go-grpc_out=./internal/pkg/chat/generated/ \
 --go-grpc_opt=paths=source_relative
```

## Клиент:

```bash
# Для чата
protoc --swift_out=. chat.proto 
protoc --grpc-swift_out=. chat.proto

# Для калькултятора
protoc --swift_out=. calc.proto 
protoc --grpc-swift_out=. calc.proto
```
