package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"

	"github.com/ahysing/lazychat/pkg/lazychat"
)

var addr = flag.String("addr", ":8080", "http service address")

func serveHome(w http.ResponseWriter, r *http.Request) {
	log.Println(r.URL)
	if r.URL.Path != "/" {
		http.Error(w, "Not found", 404)
		return
	}
	if r.Method != "GET" {
		http.Error(w, "Method not allowed", 405)
		return
	}
	http.ServeFile(w, r, "web/index.html")
}

func main() {
	flag.Parse()
	hub := lazychat.NewHub()
	go hub.Run()
	http.HandleFunc("/", serveHome)
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		lazychat.ServeWs(hub, w, r)
	})
	fmt.Printf("Listening on http://localhost%s/\n", *addr)
	err := http.ListenAndServe(*addr, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
