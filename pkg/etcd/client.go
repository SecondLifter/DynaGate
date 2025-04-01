package etcd

import (
	"context"
	"time"

	clientv3 "go.etcd.io/etcd/client/v3"
)

type Client struct {
	client *clientv3.Client
}

func NewClient(endpoints []string, timeout time.Duration) (*Client, error) {
	cli, err := clientv3.New(clientv3.Config{
		Endpoints:   endpoints,
		DialTimeout: timeout,
	})
	if err != nil {
		return nil, err
	}
	return &Client{client: cli}, nil
}

func (c *Client) Get(ctx context.Context, key string) (*clientv3.GetResponse, error) {
	return c.client.Get(ctx, key)
}

func (c *Client) Put(ctx context.Context, key, value string) (*clientv3.PutResponse, error) {
	return c.client.Put(ctx, key, value)
}

func (c *Client) Delete(ctx context.Context, key string) (*clientv3.DeleteResponse, error) {
	return c.client.Delete(ctx, key)
}

func (c *Client) Watch(ctx context.Context, key string) clientv3.WatchChan {
	return c.client.Watch(ctx, key)
}

func (c *Client) Close() error {
	return c.client.Close()
}
