package calc

import (
	"context"
	"gRPC-Service/internal/pkg/calc/generated"
	"io"
)

// Add Реализация метода суммы
func (s *calcService) Add(ctx context.Context, req *proto.AddRequest) (*proto.AddResponse, error) {
	sum := req.GetFirstNumber() + req.GetSecondNumber()
	res := &proto.AddResponse{
		SumResult: sum,
	}
	return res, nil
}

// FindMaximum Реализация метода поиска максимума
func (s *calcService) FindMaximum(stream proto.Calc_FindMaximumServer) error {
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
			if err := stream.Send(&proto.FindMaximumResponse{Maximum: maxNumber}); err != nil {
				return err
			}
		}
	}
}

// Fibo Реализация метода фибоначчи
func (s *calcService) Fibo(req *proto.FiboRequest, stream proto.Calc_FiboServer) error {
	a, b := 0, 1
	for i := 0; i < int(req.Num); i++ {
		if err := stream.Send(&proto.FiboResponse{Num: int64(a)}); err != nil {
			return err
		}
		a, b = b, a+b
	}
	return nil
}

// ComputeAverage Реализация метода вычисления среднего
func (s *calcService) ComputeAverage(stream proto.Calc_ComputeAverageServer) error {
	var sum int32
	var count int32

	for {
		req, err := stream.Recv()
		if err == io.EOF {
			average := float64(sum) / float64(count)
			return stream.SendAndClose(&proto.ComputeAverageResponse{
				Average: average,
			})
		}
		if err != nil {
			return err
		}

		sum += req.GetNumber()
		count++
	}
}
