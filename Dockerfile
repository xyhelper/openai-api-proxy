# 第一阶段：使用Golang镜像来编译应用程序
FROM golang:latest AS builder

# 在容器中创建应用目录
RUN mkdir /app

# 将当前工作目录复制到容器中的/app目录
ADD . /app

# 设置容器的工作目录
WORKDIR /app

# 使用Go Modules安装所需的依赖项
RUN go mod tidy

# 编译应用程序
RUN go build -o main .

# 第二阶段：使用Ubuntu镜像来运行应用程序
FROM ubuntu:latest

# 安装所需的软件包
RUN apt-get update && apt-get install -y \
    ca-certificates

# 从第一阶段中的Golang镜像中复制应用程序到Ubuntu镜像中
COPY --from=builder /app/main /usr/local/bin/main

# 设置应用程序的默认环境变量
ENV GIN_MODE=release

# 暴露应用程序的默认端口
EXPOSE 8080

# 启动应用程序
CMD ["/usr/local/bin/main"]
