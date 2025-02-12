package handlers

import (
	"embed"
	"fmt"
	"html/template"
	"net/http"

	"github.com/spf13/viper"
	"q-sw.xyz/web/logger"
)

func IndexHandler(w http.ResponseWriter, r *http.Request, templates embed.FS) {
	l := logger.NewLogger()
	//tmpl, err := template.ParseFiles("./templates/base.html", "./templates/index.html")
	tmpl, err := template.ParseFS(templates, "templates/base.html", "templates/index.html")

	if err != nil {
		l.Error(fmt.Sprintf("Error to parse template with error: %v", err))
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("/opt")
	errConfig := viper.ReadInConfig()
	if errConfig != nil {
		fmt.Println("Error to loading the config file")
	}

	img := viper.GetString("image")
	fmt.Println(img)

	err = tmpl.Execute(w, map[string]string{"img": img})
	if err != nil {
		l.Error(fmt.Sprintf("Error to render template with err %v", err))
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}
