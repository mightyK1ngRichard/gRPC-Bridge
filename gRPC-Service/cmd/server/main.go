package main

import (
	"gRPC-Service/internal/models"
	"gRPC-Service/internal/pkg/calc"
	calcPb "gRPC-Service/internal/pkg/calc/generated"
	"gRPC-Service/internal/pkg/chat"
	chatPb "gRPC-Service/internal/pkg/chat/generated"
	"google.golang.org/grpc"
	"log"
	"net"
)

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Ошибка при попытке слушать: %v", err)
	}

	s := grpc.NewServer()

	// Регистрируем CalcService
	calcPb.RegisterCalcServer(s, calc.NewCalcService())

	// Регистрируем ChatService
	var connections []*models.Connection
	pool := &chat.Pool{
		Connections: connections,
	}
	chatPb.RegisterBroadcastServer(s, pool)

	log.Println("Сервер gRPC запущен на порту :50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("Ошибка запуска gRPC-сервера: %v", err)
	}
}
