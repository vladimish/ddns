package client

import (
	"fmt"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"

	"github.com/vladimish/ddns/bridge/pkg/abigen/ownership"
)

type Ethereum struct {
	client  *ethclient.Client
	address common.Address
	apiKey  string
}

func NewEthereum(apiKey string) *Ethereum {
	return &Ethereum{
		apiKey: apiKey,
	}
}

const url = "https://sepolia.infura.io/v3/"

func (i *Ethereum) InitializeClient() error {
	client, err := ethclient.Dial(url + i.apiKey)
	if err != nil {
		return fmt.Errorf("failed to initialize client: %w", err)
	}

	// TODO: move to config
	i.address = common.HexToAddress("0x6c28a7408462375EfBF177AbE53454DCD9763373")
	i.client = client
	return nil
}

func (i *Ethereum) GetRecord(str string) (string, error) {
	o, err := ownership.NewOwnership(i.address, i.client)
	if err != nil {
		return "", fmt.Errorf("can't get ownership contract: %w", err)
	}
	res, err := o.GetRecord(nil, str)
	if err != nil {
		return "", fmt.Errorf("can't get record: %w", err)
	}

	return res, nil
}
