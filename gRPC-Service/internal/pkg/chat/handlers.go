package chat

import (
	"context"
	"fmt"
	"gRPC-Service/internal/models"
	proto "gRPC-Service/internal/pkg/chat/generated"
	"sync"
)

func (p *Pool) CreateStream(pconn *proto.Connect, stream proto.Broadcast_CreateStreamServer) error {
	conn := &models.Connection{
		Stream: stream,
		Id:     pconn.User.Id,
		Active: true,
		Error:  make(chan error),
	}

	p.Connections = append(p.Connections, conn)

	return <-conn.Error
}

func (p *Pool) BroadcastMessage(ctx context.Context, msg *proto.Message) (*proto.Close, error) {
	wait := sync.WaitGroup{}
	done := make(chan int)

	for _, conn := range p.Connections {
		wait.Add(1)

		go func(msg *proto.Message, conn *models.Connection) {
			defer wait.Done()

			if conn.Active {
				err := conn.Stream.Send(msg)
				fmt.Printf("Sending message to: %v from %v", conn.Id, msg.Id)

				if err != nil {
					fmt.Printf("Error with Stream: %v - Error: %v\n", conn.Stream, err)
					conn.Active = false
					conn.Error <- err
				}
			}
		}(msg, conn)
	}

	go func() {
		wait.Wait()
		close(done)
	}()

	<-done
	return &proto.Close{}, nil
}
