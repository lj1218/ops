## nginx纯tcp代理实现负载均衡

### Author

[lj1218](mailto:lj_ebox@163.com)

### nginx 编译及安装

> 注意：nginx 支持 tcp 代理，必须在编译时添加 `--with-stream` 选项。

```bash
# 下载地址：https://nginx.org/en/download.html
wget https://nginx.org/download/nginx-1.16.0.tar.gz && \
tar zxf nginx-1.16.0.tar.gz && cd nginx-1.16.0 && ./configure --with-stream && make && cd objs
```

> 注：我们这里不安装 `nginx`，进入 `objs` 目录直接运行 `nginx` 即可。

### 配置 TCP 负载均衡（TCP Load Balancing）

参见：

- https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/
- https://www.cnblogs.com/cheyunhua/p/8807161.html

配置文件 `nginx.conf` 内容如下：

```
user  nginx; # 若系统无 nginx 用户，则需新建，或者改为 root 用户。
worker_processes  1;  # 工作进程个数，可以适当增加

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


# https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/
stream {
    server {
        listen 8888 so_keepalive=on;  # 添加长连接设置
        #TCP traffic will be forwarded to the "stream_backend" upstream group
        proxy_pass stream_backend;
        #proxy_buffer_size 16k;
        proxy_timeout 3s;
        proxy_connect_timeout 1s;
        tcp_nodelay on;
    }

    upstream stream_backend {
        least_conn;
        server 127.0.0.1:8001;
        server 127.0.0.1:8002;
        server 127.0.0.1:8003;
        server 127.0.0.1:8004;
        server 127.0.0.1:8005;
    }
}
```

### 启动 nginx

```bash
mkdir -p /var/log/nginx
./nginx -c /path/to/nginx.conf  # 必须使用绝对路径
```

#### 排错

启动 nginx 出现 bind() to 0.0.0.0:8888 failed (13: Permission denied)，解决办法参见：[重启Nginx出现bind() to 0.0.0.0:8088 failed (13: Permission denied)](https://www.linuxidc.com/Linux/2019-02/157121.htm)

```bash
# 要查看selinux允许的http端口必须使用semanage命令，下面首先安装semanage命令工具
# 直接通过yum安装发现semanage发现没有此包
# 先查找semanage命令是哪个软件包提供此命令
$ yum provides semanage
# 我们发现需要安装包policycoreutils-python才能使用semanage命令
$ yum install policycoreutils-python
# 现在终于可以使用semanage了，我们先查看下http允许访问的端口：
$ semanage port -l | grep http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
# 然后我们将需要使用的端口8088加入到端口列表中：
$ semanage port -a -t http_port_t -p tcp 8888
$ semanage port -l | grep http_port_t
http_port_t                    tcp      8888, 80, 81, 443, 488, 8008, 8009, 8443, 9000
# 好了现在nginx可以使用8888端口了
```

> 注：该报错是没有使用编译选项 --with-stream 的 nginx 版本，因此它只支持 http 代理（若支持纯 tcp 代理的版本不会报这个错误）
