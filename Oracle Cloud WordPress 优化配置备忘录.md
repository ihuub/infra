# Oracle Cloud WordPress 优化配置备忘录

**生成时间**: 2026年11月15日

**服务器架构**: ARM64 (2 OCPU, 12GB RAM)

**环境组件**: Nginx, PHP 8.3, MariaDB 10.11, Redis

**4个插件**: 终极会员(用户登录注册和管理)；Redis Object Cache；TaxoPress(标签管理)；Loggedin - Limit Concurrent Sessions


## 1. MariaDB 10.11 数据库配置

`systemctl restart mariadb`

`my_print_defaults mysqld`显示配置文件解析出的参数

`mariadb -e "
SHOW GLOBAL VARIABLES
WHERE Variable_name IN (
'innodb_flush_log_at_trx_commit',
'max_connections',
'innodb_buffer_pool_size',
'innodb_buffer_pool_dump_at_shutdown',
'innodb_buffer_pool_load_at_startup'
);"` 查询运行中的参数

**文件路径**: `/etc/mysql/mariadb.conf.d/50-server.cnf`

> **说明**: 利用大内存优势减少磁盘读取，优化写入策略。

```ini
[mysqld]

# I/O 写入优化 (极大提升写入性能)
innodb_flush_log_at_trx_commit = 1

# 最大连接数
max_connections = 60

innodb_buffer_pool_size = 4G

#默认开启
innodb_buffer_pool_dump_at_shutdown = ON/innodb_buffer_pool_load_at_startup = ON
```

---

## 2. PHP 8.3 FPM 进程池配置

`systemctl restart php8.3-fpm`

`php-fpm8.3 -tt` 查看配置

**文件路径**: `/etc/php/8.3/fpm/pool.d/www.conf`

**php_admin_value[memory_limit]要写在pool路径下**

```ini
; 进程管理模式
pm = dynamic

; 最大子进程 (防止 CPU 100% 卡死)
pm.max_children = 12

; 启动与空闲进程控制
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6

pm.max_requests = 500
php_admin_value[memory_limit] = 256M

```

---

## 3. PHP Opcache 配置

`php -i | grep -E 'opcache.enable|opcache.enable_cli|opcache.memory_consumption|opcache.interned_strings_buffer|opcache.max_accelerated_files|opcache.validate_timestamps|opcache.revalidate_freq'`  查看配置


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
opcache.max_accelerated_files=10000

opcache.validate_timestamps=1
opcache.revalidate_freq=60

```

---

## 4. Redis 服务器配置

`systemctl restart redis-server`

`redis-cli CONFIG GET bind protected-mode  maxmemory maxmemory-policy  save appendonly` 查询运行中的配置

**文件路径**: `/etc/redis/redis.conf`

> **说明**: 限制最大内存防止系统 OOM，采用 LRU 算法自动清理旧缓存。

```conf
# 只允许本机访问，-表示该地址绑定失败时，不要因此导致 Redis 启动失败
bind 127.0.0.1 -::1

# 防止不安全的远程访问
protected-mode yes

# Redis 最大内存
maxmemory 512mb

# 达到内存限制时淘汰最近较少使用的键
maxmemory-policy allkeys-lru

# 关闭 RDB 定时持久化
save ""

# 关闭 AOF
appendonly no

```

---

## 5. WordPress 配置文件

**文件路径**: `wp-config.php` (位于网站根目录)

```php
// --- Redis TCP 连接配置 (删除 SCHEME 和 PATH) ---
define('WP_REDIS_HOST', '127.0.0.1');
define('WP_REDIS_PORT', 6379);

define('WP_REDIS_PERSISTENT', true);
define('WP_REDIS_DATABASE', 0);
define('WP_REDIS_TIMEOUT', 1);
define('WP_REDIS_READ_TIMEOUT', 1);

```
