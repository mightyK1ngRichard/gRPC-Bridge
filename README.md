# Swift+Go+gRPC

## Quick start

### Сервер:

1. Скачать проект
```bash
git clone https://github.com/mightyK1ngRichard/gRPC-Bridge.git
```

2. Открыть корень бэкенда:
```bash
cd gRPC-Bridge/gRPC-Service
```

3. Запуск gRPC сервиса:
```bash
make start
```

Пример успешного запуска:
```docker
docker-compose up
[+] Running 1/0
 ✔ Container grpc-service-grpc-service-1  Created                                                            0.0s 
Attaching to grpc-service-1
grpc-service-1  | 2024/10/23 14:26:22 Сервер gRPC запущен на порту :50051
```

Всё, бэкенд запущен.

### Клиент:

Вернуться в корень репозитория и открыть папку iOS-приложение
```shell
bash 
cd iOS-App && open gRPC-App.xcodeproj
```
Xcode открылся!

## Команды кодгена:

### Для GoLang:

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

### Для Swift:

```bash
# Для чата
protoc --swift_out=. chat.proto 
protoc --grpc-swift_out=. chat.proto

# Для калькултятора
protoc --swift_out=. calc.proto 
protoc --grpc-swift_out=. calc.proto
```

Ну и плагины для swift:

Для возможности кодгена прото файлов для клиента на Swift надо скачать:
```bash
brew install swift-protobuf grpc-swift
```
