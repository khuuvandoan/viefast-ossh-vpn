#!/bin/bash

echo "🔧 Cài đặt VieFast OSSH SOCKS5 VPN (Chuẩn systemd)"

# Nhập SSH host (IP hoặc domain)
read -p "🌐 Nhập SSH host (IP hoặc domain): " SSH_HOST

# Nhập SSH user (mặc định là vpnuser)
read -p "👤 Nhập SSH username [vpnuser]: " SSH_USER
SSH_USER=${SSH_USER:-vpnuser}

# Port & cấu hình
SSH_PORT=22
SOCKS_PORT=1080

# Kiểm tra autossh đã cài chưa
if ! command -v autossh &> /dev/null; then
  echo "📦 Cài đặt autossh..."
  sudo apt update && sudo apt install -y autossh
fi

# Lấy đường dẫn tuyệt đối của autossh
AUTOSSH_BIN=$(which autossh)

# Tạo systemd service
echo "📝 Tạo systemd service..."

sudo tee /etc/systemd/system/viefast-ossh.service > /dev/null <<EOF
[Unit]
Description=VieFast OSSH SOCKS5 VPN
After=network.target

[Service]
ExecStart=$AUTOSSH_BIN -M 0 -N -D 0.0.0.0:$SOCKS_PORT -p $SSH_PORT $SSH_USER@$SSH_HOST
Restart=always
RestartSec=5
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# Khởi động lại systemd và enable dịch vụ
echo "🚀 Kích hoạt dịch vụ..."

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable viefast-ossh
sudo systemctl restart viefast-ossh

# Kiểm tra trạng thái
echo ""
sudo systemctl status viefast-ossh --no-pager

# IP public
IP=$(curl -s ifconfig.me)

echo ""
echo "✅ ĐÃ CÀI ĐẶT THÀNH CÔNG!"
echo "🌐 SOCKS5 proxy qua SSH sẵn sàng tại:"
echo "👉 Host: $IP"
echo "👉 Port: $SOCKS_PORT"
echo "📱 Dùng với Shadowrocket, V2RayNG, ProxyDroid..."
