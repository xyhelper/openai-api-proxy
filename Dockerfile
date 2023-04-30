# 基础镜像
FROM golang:latest

# 在容器中创建应用目录
RUN mkdir /app

# 将当前工作目录复制到容器中的/app目录
ADD . /app

# 设置容器的工作目录
WORKDIR /app

# 使用Go Modules安装所需的依赖项
RUN go mod download

# 编译应用程序
RUN go build -o main .

# 创建新的容器并将应用程序复制到容器中
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=0 /app/main /usr/local/bin/main
RUN chmod +x /usr/local/bin/main

# 暴露应用程序的默认端口
EXPOSE 8080

# 设置应用程序的默认环境变量
ENV GIN_MODE=release

# 启动应用程序
CMD ["main"]
