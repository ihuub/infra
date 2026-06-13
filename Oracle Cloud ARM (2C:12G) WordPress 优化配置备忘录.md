# Oracle Cloud ARM (2C/12G) WordPress 优化配置备忘录

**生成时间**: 2026年02月03日
**服务器架构**: ARM64 (2 vCPU, 12GB RAM)
**环境组件**: Nginx, PHP 8.3, MariaDB 10.11, Redis

## 1. MariaDB 10.11 数据库配置

`systemctl restart mariadb`

**文件路径**: `/etc/mysql/mariadb.conf.d/50-server.cnf`

> **说明**: 利用大内存优势减少磁盘读取，优化写入策略。

```ini
[mysqld]

# I/O 写入优化 (极大提升写入性能)
innodb_flush_log_at_trx_commit = 2

# 最大连接数
max_connections = 150

# 核心内存分配 (总内存的 50%)
innodb_buffer_pool_size = 2G
```

---

## 2. PHP 8.3 FPM 进程池配置

`systemctl restart php8.3-fpm`

**文件路径**: `/etc/php/8.3/fpm/pool.d/www.conf`

> **说明**: 限制子进程数量以保护 2 核 CPU 不被过载，同时给予充足的内存。

```ini
; 进程管理模式
pm = dynamic

; 最大子进程 (防止 CPU 100% 卡死)
pm.max_children = 8

; 启动与空闲进程控制
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

; 单进程内存限制
php_admin_value[memory_limit] = 256M

```

---

## 3. PHP Opcache 配置

**文件路径**: `/etc/php/8.3/fpm/conf.d/10-opcache.ini`

```ini
zend_extension=opcache.so

; 开启 Opcache
opcache.enable=1
opcache.enable_cli=0

; 内存消耗配置 (MB)
opcache.memory_consumption=256
opcache.interned_strings_buffer=16

; 最大缓存文件数
opcache.max_accelerated_files=20000

```

---

## 4. Redis 服务器配置

**文件路径**: `/etc/redis/redis.conf`

> **说明**: 限制最大内存防止系统 OOM，采用 LRU 算法自动清理旧缓存。

```conf
# 内存上限
maxmemory 1gb

# 内存淘汰策略 (所有键中使用 LRU 算法)
maxmemory-policy allkeys-lru

```

---

## 5. WordPress 配置文件

**文件路径**: `wp-config.php` (位于网站根目录)

> **说明**: 连接 Redis 并开启 WordPress 缓存机制。

```php
// 开启缓存总开关
define( 'WP_CACHE', true );

// Redis TCP 连接配置
define( 'WP_REDIS_HOST', '127.0.0.1' );
define( 'WP_REDIS_PORT', 6379 );

```
