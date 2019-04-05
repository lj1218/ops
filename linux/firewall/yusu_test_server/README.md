## 测试服务器防火墙规则设置脚本（含端口转发）

### 功能描述

    1. 10.199.109.70 不能主动访问 10.199.109.0/24，但 10.199.109.0/24 可以 ssh  
       到 10.199.109.70 进行管理
    2. 端口流量转发: 10.199.109.70:21000 -> 10.199.103.219:21000

### 脚本说明

    1. fw_rule_with_socat.sh: 使用 socat 做端口转发
    2. fw_rule_with_rinetd.sh: 使用 rinetd 做端口转发
    3. fw_rule_with_ssh.sh: 使用 ssh 做端口转发
    4. fw_rule.sh: 无端口转发

### 脚本运行命令

```bash
sh fw_rule*.sh <start | stop | restart>
```

### rinetd端口转发工具

官网：[https://boutell.com/rinetd/](https://boutell.com/rinetd/)
