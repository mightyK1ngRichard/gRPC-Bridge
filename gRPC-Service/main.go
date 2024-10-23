//package main
//
//import (
//	"fmt"
//	pb "gRPC-Service/gen/go"
//	"google.golang.org/grpc"
//	"log"
//	"net"
//	"sync"
//)
//
//type echoServer struct {
//	pb.UnimplementedEchoServiceServer
//	mu      sync.Mutex
//	clients []chan *pb.Message
//}
//
//func (s *echoServer) BroadcastMessage(msg *pb.Message, stream pb.EchoService_BroadcastMessageServer) error {
//	clientChan := make(chan *pb.Message, 10)
//
//	s.mu.Lock()
//	s.clients = append(s.clients, clientChan)
//	s.mu.Unlock()
//
//	defer func() {
//		// Убираем канал клиента, когда поток заканчивается
//		s.mu.Lock()
//		defer s.mu.Unlock()
//		for i, c := range s.clients {
//			if c == clientChan {
//				s.clients = append(s.clients[:i], s.clients[i+1:]...)
//				break
//			}
//		}
//		close(clientChan)
//	}()
//
//	// Распространяем сообщения всем клиентам
//	go func() {
//		for {
//			select {
//			case m := <-clientChan:
//				if err := stream.Send(m); err != nil {
//					log.Printf("Ошибка при отправке сообщения: %v", err)
//					return
//				}
//			case <-stream.Context().Done():
//				// Если контекст потока завершён, выходим из горутины
//				return
//			}
//		}
//	}()
//
//	// Получаем сообщения от этого клиента и распространяем их на других
//	s.mu.Lock()
//	defer s.mu.Unlock()
//	for _, client := range s.clients {
//		if client != clientChan {
//			client <- msg
//		}
//	}
//
//	return nil
//}
//
//func main() {
//	lis, err := net.Listen("tcp", ":50051")
//	if err != nil {
//		log.Fatalf("Failed to listen: %v", err)
//	}
//	grpcServer := grpc.NewServer()
//	pb.RegisterEchoServiceServer(grpcServer, &echoServer{})
//	fmt.Println("Server is running on port 50051")
//	if err := grpcServer.Serve(lis); err != nil {
//		log.Fatalf("Failed to serve: %v", err)
//	}
//}

package main

import (
	"context"
	pb "gRPC-Service/gen/go"
	"google.golang.org/grpc"
	"io"
	"log"
	"net"
)

type server struct {
	pb.UnimplementedCalcServer
}

func (s *server) Add(ctx context.Context, req *pb.AddRequest) (*pb.AddResponse, error) {
	sum := req.GetFirstNumber() + req.GetSecondNumber()
	res := &pb.AddResponse{
		SumResult: sum,
	}
	return res, nil
}

func (s *server) FindMaximum(stream pb.Calc_FindMaximumServer) error {
	var maxNumber int32
	for {
		req, err := stream.Recv()
		if err == io.EOF {
			return nil
		}
		if err != nil {
			return err
		}

		if req.Number > maxNumber {
			maxNumber = req.Number
			// Отправляем обратно обновленное максимальное число
			if err := stream.Send(&pb.FindMaximumResponse{Maximum: maxNumber}); err != nil {
				return err
			}
		}
	}
}

func (s *server) ComputeAverage(stream pb.Calc_ComputeAverageServer) error {
	var sum int32
	var count int32

	for {
		// Читаем сообщения от клиента
		req, err := stream.Recv()
		if err == io.EOF {
			// Когда клиент завершает отправку данных, возвращаем среднее значение
			average := float64(sum) / float64(count)
			return stream.SendAndClose(&pb.ComputeAverageResponse{
				Average: average,
			})
		}
		if err != nil {
			return err
		}

		// Обновляем сумму и количество полученных чисел
		sum += req.GetNumber()
		count++
	}
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Ошибка при попытке слушать: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterCalcServer(s, &server{})

	log.Println("Сервер gRPC запущен на порту :50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("Ошибка запуска gRPC-сервера: %v", err)
	}
}
