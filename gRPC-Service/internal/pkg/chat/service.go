package chat

import (
	"gRPC-Service/internal/models"
	proto "gRPC-Service/internal/pkg/chat/generated"
)

type Pool struct {
	proto.UnimplementedBroadcastServer
	Connections []*models.Connection
}
