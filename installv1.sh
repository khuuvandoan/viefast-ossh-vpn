#!/bin/bash

# ======= CẤU HÌNH TÙY CHỈNH ========
SSH_USER="vpnuser"
SSH_HOST="vpn.viefast.net"
SSH_PORT=22
SOCKS_PORT=1080
CLASH_PORT=7890
# ==================================

echo "🛠️ Cài đặt VieFast OSSH VPN + Clash Meta..."

# 1. Cài đặt yêu cầu
sudo apt update && sudo apt install curl wget unzip -y

# 2. Tải Clash Meta
mkdir -p ~/viefast-ossh
cd ~/viefast-ossh
wget -O clash-meta.tar.gz https://github.com/MetaCubeX/mihomo/releases/download/v1.16.0/mihomo-linux-amd64-v1.16.0.gz
gunzip mihomo-linux-amd64-v1.16.0.gz
mv mihomo-linux-amd64-v1.16.0 clash-meta
chmod +x clash-meta

# 3. Tạo SSH tunnel script
cat <<EOF > start-ossh.sh
#!/bin/bash
ssh -f -N -D $SOCKS_PORT -p $SSH_PORT $SSH_USER@$SSH_HOST
EOF

chmod +x start-ossh.sh

# 4. Tạo config.yaml cho Clash Meta
cat <<EOF > config.yaml
mixed-port: $CLASH_PORT
allow-lan: true
mode: global

proxies:
  - name: VieFast-OSSH
    type: socks5
    server: 127.0.0.1
    port: $SOCKS_PORT
    socks5-auth: false
    udp: true

proxy-groups:
  - name: Auto
    type: select
    proxies:
      - VieFast-OSSH

rules:
  - MATCH,Auto
EOF

# 5. Tạo systemd service để khởi động cùng hệ thống
cat <<EOF | sudo tee /etc/systemd/system/viefast-ossh.service
[Unit]
Description=VieFast OSSH VPN + Clash Meta
After=network.target

[Service]
User=$USER
WorkingDirectory=/home/$USER/viefast-ossh
ExecStart=/bin/bash -c "./start-ossh.sh && ./clash-meta -f config.yaml"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 6. Kích hoạt dịch vụ
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable viefast-ossh
sudo systemctl start viefast-ossh

echo "✅ VieFast VPN OSSH đã cài đặt và chạy ngầm!"
echo "🔁 Bạn có thể kiểm tra với: sudo systemctl status viefast-ossh"
