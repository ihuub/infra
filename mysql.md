# Ubuntu 24.04 MySQL 安装与安全配置指南

## 1. 更新系统软件包

```bash
apt update && sudo apt upgrade -y
```

## 2. 安装 MySQL Server

```bash
apt install mysql-server -y
```

## 3. 安全配置 (必须执行)

运行 MySQL 自带的安全设置脚本，以锁定数据库访问权限：

```bash
mysql_secure_installation
```

**建议选择：**
1. **VALIDATE PASSWORD COMPONENT**: 输入 `n` (开启强密码检查)。
2. **Remove anonymous users**: 输入 `y` (删除匿名用户)。
3. **Disallow root login remotely**: 输入 `y` (禁止远程 root 登录，提升安全性)。
4. **Remove test database**: 输入 `y` (删除测试库)。
5. **Reload privilege tables**: 输入 `y` (立即生效)。

## 4. 管理员账户配置

#### 4.1 进入 MySQL 控制台
```bash
mysql -u root -p
```

#### 4.2 创建数据库
创建一个支持 UTF-8 编码（推荐）的数据库：
```sql
CREATE DATABASE cloudreve CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 4.3 创建用户并授权

**步骤 1：创建用户**
```sql
CREATE USER 'cloudreve'@'localhost' IDENTIFIED BY 'password';
```

**步骤 2：授予权限**
```sql
GRANT ALL PRIVILEGES ON `cloudreve`.* TO 'cloudreve'@'localhost';
```

**步骤 3：刷新权限并退出**
```sql
FLUSH PRIVILEGES;
EXIT;
```
