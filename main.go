package main

import (
	"embed"

	"q-sw.xyz/web/server"
)

//go:embed templates
var templates embed.FS

func main() {
	srv := server.ServerCfg{
		ListenPort: ":8080",
		Templates:  templates,
	}

	srv.Run()
}
