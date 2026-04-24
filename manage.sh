#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "错误：请使用 sudo 或 root 账号运行此脚本。"
    exit 1
fi

echo "---------- 请选择要执行的操作 ----------"
echo "1) 开启 BBR (修改 sysctl.conf 并 sysctl -p 查看)"
echo "2) 设置上海时区"
echo "3) 限制 Journald 日志 20M/10M"
echo "4) 限制 Journald 日志 100M/50M"
echo "5) systemctl restart systemd-journald"
echo "6) apt update && apt upgrade -y"
echo "7) apt dist-upgrade -y"
echo "8) nginx -t && systemctl restart nginx"
echo "9) truncate 清空 nginx 日志"
echo "10) 清空 fail2ban 日志并重启"
echo "11) systemctl enable nftables"
echo "12) systemctl restart nftables"
echo "13) nft list ruleset"
echo "14) systemctl enable xray"
echo "15) 重启 xray 并查看状态"
echo "16) find 删除 /var/log 多余日志"
echo "17) 给予 nginx 对 f2b 日志文件的读取权限"
echo "18) 修改 mtu 后 netplan apply"
echo "19) systemctl enable systemctl restart systemctl status"
echo "20) tcpdump -ni any port 22 and ip6"
echo "21) ss -lptn 'sport = :443' "
echo "q) 退出"
echo "---------------------------------------"

read -p "请输入编号 [1-18/q]: " choice

# 定义一个辅助函数
run_cmd() {
    echo -e "\n[执行命令]: $1"
    eval "$1"
}

case $choice in
    1)
        run_cmd "grep -q 'net.core.default_qdisc=fq' /etc/sysctl.conf || echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf"
        run_cmd "grep -q 'net.ipv4.tcp_congestion_control=bbr' /etc/sysctl.conf || echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf"
        run_cmd "sysctl -p"
        ;;
    2)
        run_cmd "timedatectl set-timezone Asia/Shanghai"
        run_cmd "timedatectl"
        ;;
    3)
        run_cmd "sed -i -e 's/^#\?SystemMaxUse=.*/SystemMaxUse=20M/' -e 's/^#\?SystemMaxFileSize=.*/SystemMaxFileSize=10M/' /etc/systemd/journald.conf"        
        ;;
    4)
        run_cmd "sed -i -e 's/^#\?SystemMaxUse=.*/SystemMaxUse=100M/' -e 's/^#\?SystemMaxFileSize=.*/SystemMaxFileSize=50M/' /etc/systemd/journald.conf"        
        ;;
    5)
        run_cmd "systemctl restart systemd-journald"
        ;;
    6)
        run_cmd "apt update && apt upgrade -y"
        ;;
    7)
        run_cmd "apt dist-upgrade -y"
        ;;
    8)
        run_cmd "nginx -t && systemctl restart nginx"
        ;;
    9)
        run_cmd "truncate -s 0 /var/log/nginx/error.log /var/log/nginx/access.log"        
        ;;
    10)
        run_cmd "truncate -s 0 /var/log/fail2ban.log && systemctl restart fail2ban"        
        ;;
    11)
        run_cmd "systemctl enable nftables"
        ;;
    12)
        run_cmd "systemctl restart nftables"
        ;;
    13)
        run_cmd "nft list ruleset"
        ;;
    14)
        run_cmd "systemctl enable xray"
        ;;
    15)
        run_cmd "systemctl restart xray"
        run_cmd "systemctl status xray --no-pager"
        ;;
    16)
        run_cmd "find /var/log -type f -regex '.*\.[01]' -print -delete"
        ;;
    17)
        # 增加判断，防止 setfacl 未安装导致报错
        if command -v setfacl >/dev/null; then
            run_cmd "setfacl -m u:nginx:r /var/log/fail2ban.log"
        else
            echo "错误：未安装 acl 工具，请先执行 apt install acl"
        fi
        ;;
    18)
        run_cmd "netplan apply"
        ;;
    q)
        exit 0
        ;;
    *)
        exit 1
        ;;
esac

echo -e "\n---------------------------------------"
echo "任务处理完成！"
