package main

import (
	"net/http"
	"net/http/httputil"
	"net/url"

	"github.com/gin-gonic/gin"
)

func main() {
	// 创建一个Gin实例
	router := gin.Default()

	// 创建反向代理处理程序
	targetURL, _ := url.Parse("https://api.openai.com")
	proxy := httputil.NewSingleHostReverseProxy(targetURL)

	// 创建一个中间件函数来删除标头
	removeHeaders := func(c *gin.Context) {
		c.Request.Header.Del("CF-Connecting-IP")
		c.Request.Header.Del("X-Forwarded-For")
		c.Request.Header.Del("X-Real-IP")
	}

	// 创建一个处理程序函数来代理所有请求
	proxyHandler := func(c *gin.Context) {
		// 删除标头
		removeHeaders(c)

		// 代理请求
		proxy.ServeHTTP(c.Writer, c.Request)
	}

	// 将所有请求代理到目标URL
	router.NoRoute(proxyHandler)

	// 添加/路由来显示欢迎消息
	router.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "Welcome to the OpenAI API proxy!"})
	})

	// 添加/ping路由来检查服务状态
	router.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "pong"})
	})

	// 启动服务器
	router.Run()
}
