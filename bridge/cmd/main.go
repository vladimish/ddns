package main

import (
	"log"
	"net"
	"strconv"

	"github.com/miekg/dns"

	"github.com/vladimish/ddns/bridge/pkg/client"
)

type handler struct {
	e *client.Ethereum
}

func (h *handler) ServeDNS(w dns.ResponseWriter, r *dns.Msg) {
	msg := dns.Msg{}
	msg.SetReply(r)
	switch r.Question[0].Qtype {
	case dns.TypeA:
		msg.Authoritative = true
		domain := msg.Question[0].Name
		address, err := h.e.GetRecord(domain)
		if err != nil {
			panic(err)
		}
		msg.Answer = append(msg.Answer, &dns.A{
			Hdr: dns.RR_Header{Name: domain, Rrtype: dns.TypeA, Class: dns.ClassINET, Ttl: 60},
			A:   net.ParseIP(address),
		})
	}
	err := w.WriteMsg(&msg)
	if err != nil {
		panic(err)
	}
}

func main() {
	// TODO: move to config
	e := client.NewEthereum("")
	err := e.InitializeClient()
	if err != nil {
		log.Fatal(err)
	}

	srv := &dns.Server{Addr: ":" + strconv.Itoa(53), Net: "udp"}
	srv.Handler = &handler{
		e: e,
	}

	if err := srv.ListenAndServe(); err != nil {
		log.Fatalf("Failed to set udp listener %s\n", err.Error())
	}
}
