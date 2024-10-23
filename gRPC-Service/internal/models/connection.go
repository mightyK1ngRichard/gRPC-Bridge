package models

import (
	chatProto "gRPC-Service/internal/pkg/chat/generated"
)

type Connection struct {
	chatProto.UnimplementedBroadcastServer
	Stream chatProto.Broadcast_CreateStreamServer
	Id     string
	Active bool
	Error  chan error
}
