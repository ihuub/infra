# Ubuntu 24.04 MySQL 安装与安全配置指南

## 1. 更新系统软件包

sudo apt update && sudo apt upgrade -y


## 2. 安装 MySQL Server

Ubuntu 24.04 默认仓库中包含最新稳定版的 MySQL。

```bash
sudo apt install mysql-server -y
```

安装完成后，验证服务运行状态：

```bash
sudo systemctl status mysql
```

## 3. 安全配置 (必须执行)

运行 MySQL 自带的安全设置脚本，以锁定数据库访问权限：

```bash
sudo mysql_secure_installation
```

**建议选择：**
1. **VALIDATE PASSWORD COMPONENT**: 输入 `y` (开启强密码检查)。
2. **Password Validation Policy**: 选择 `2` (Strong，要求包含数字、大小写字母及特殊符号)。
3. **Remove anonymous users**: 输入 `y` (删除匿名用户)。
4. **Disallow root login remotely**: 输入 `y` (禁止远程 root 登录，提升安全性)。
5. **Remove test database**: 输入 `y` (删除测试库)。
6. **Reload privilege tables**: 输入 `y` (立即生效)。

## 4. 管理员账户配置

在 Ubuntu 上，MySQL 默认使用 `auth_socket` 插件，这意味着 `root` 用户无需密码即可通过 `sudo` 登录。为了开发方便或远程管理，建议创建一个具备完整权限的管理账号。

### 4.1 登录 MySQL
```bash
sudo mysql
```

### 4.2 修改 Root 密码 (可选)
如果您需要通过密码登录 root：
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '您的强密码';
FLUSH PRIVILEGES;
```

### 4.3 创建专用管理员账号 (推荐)
```sql
CREATE USER 'admin'@'localhost' IDENTIFIED BY '您的强密码';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

## 5. 开启远程访问 (慎用)

如果需要远程连接数据库，请执行以下步骤：

### 5.1 修改监听地址
编辑配置文件：
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```
找到 `bind-address` 这一行，将 `127.0.0.1` 修改为 `0.0.0.0`：
```ini
bind-address = 0.0.0.0
```
保存并退出 (Ctrl+O, Enter, Ctrl+X)。

### 5.2 防火墙放行 3306 端口
```bash
sudo ufw allow 3306/tcp
```

### 5.3 重启服务
```bash
sudo systemctl restart mysql
```

## 6. 常用管理命令

| 操作 | 命令 |
| :--- | :--- |
| 启动服务 | `sudo systemctl start mysql` |
| 停止服务 | `sudo systemctl stop mysql` |
| 设置开机自启 | `sudo systemctl enable mysql` |
| 查看运行状态 | `sudo systemctl status mysql` |
| 登录 MySQL | `mysql -u 用户名 -p` |

---

> **安全提示**: 在生产环境中，强烈建议配合 `fail2ban` 使用，并限制 `3306` 端口仅对特定的 IP 开放。

---

### 进阶建议
由于您平时关注服务器安全与性能，建议在配置完成后：
1. **监控日志**: 定期检查 `/var/log/mysql/error.log`。
2. **性能优化**: 针对 Ubuntu 24.04，可以结合 `mysqltuner` 脚本进行参数微调。
3. **备份方案**: 考虑配置 `automysqlbackup` 定时将备份同步至 GitHub 私有仓库或云存储。

是否需要我为您补充 `fail2ban` 针对 MySQL 的防护规则配置？
