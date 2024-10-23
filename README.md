# Swift+Go+gRPC

## Команды:

Устновить зависимости для swift
```bash
brew install swift-protobuf
brew install grpc-swift
```

Кодген:
```bash
# Для Swift
protoc --swift_out=. calc.proto
protoc --grpc-swift_out=. calc.proto

# Для GoLang
protoc -I proto proto/echo.proto --go_out=./gen/go/ --go_opt=paths=source_relative --go-grpc_out=./gen/go/ --go-grpc_opt=paths=source_relative
```
