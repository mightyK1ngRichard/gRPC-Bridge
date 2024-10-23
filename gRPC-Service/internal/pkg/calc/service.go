package calc

import (
	pb "gRPC-Service/internal/pkg/calc/generated"
)

// calcServer реализует gRPC-интерфейс
type calcService struct {
	pb.UnimplementedCalcServer
}

// NewCalcService создает новый экземпляр calcServer
func NewCalcService() *calcService {
	return &calcService{}
}
