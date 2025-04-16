#!/bin/bash

echo "🔧 Cài đặt VieFast OSSH SOCKS5 VPN & Danted Proxy"

# === Hỏi thông tin cần thiết ===
read -p "🌐 Nhập SSH host (IP hoặc domain): " SSH_HOST
read -p "👤 Nhập username dùng SSH (mặc định: vpnuser): " SSH_USER
SSH_USER=${SSH_USER:-vpnuser}
SSH_PORT=22
SOCKS_PORT=1080

# Thông tin SOCKS5 auth
AUTH_USER="vfastvpn"
AUTH_PASS="vpn123"

echo ""
echo "📋 Đang cài với cấu hình:"
echo "👉 SSH: $SSH_USER@$SSH_HOST:$SSH_PORT"
echo "👉 OSSH SOCKS5 proxy: 0.0.0.0:$SOCKS_PORT (no-auth)"
echo "👉 Danted SOCKS5: $SOCKS_PORT (với xác thực $AUTH_USER/$AUTH_PASS)"
echo ""

# === Cài autossh & danted ===
sudo apt update
sudo apt install -y autossh danted curl ufw

# === Tạo thư mục làm việc ===
mkdir -p ~/viefast-ossh
cd ~/viefast-ossh

# === Tạo script chạy SSH Tunnel ===
cat <<EOF > start-ossh.sh
#!/bin/bash
autossh -M 0 -f -N -D 0.0.0.0:$SOCKS_PORT -p $SSH_PORT $SSH_USER@$SSH_HOST
EOF

chmod +x start-ossh.sh

# === Tạo systemd service cho OSSH ===
cat <<EOF | sudo tee /etc/systemd/system/viefast-ossh.service
[Unit]
Description=VieFast OSSH SOCKS5 VPN
After=network.target

[Service]
User=$USER
WorkingDirectory=/home/$USER/viefast-ossh
ExecStart=/home/$USER/viefast-ossh/start-ossh.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# === Cấu hình Danted SOCKS5 ===
sudo tee /etc/danted.conf > /dev/null <<EOF
logoutput: /var/log/danted.log
internal: eth0 port = $SOCKS_PORT
external: eth0
method: username
user.notprivileged: nobody

client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect disconnect error
}

pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  protocol: tcp udp
  log: connect disconnect error
  method: username
}
EOF

# Tạo tài khoản SOCKS5
sudo useradd -M -s /usr/sbin/nologin $AUTH_USER || echo "👤 User đã tồn tại."
echo "$AUTH_USER:$AUTH_PASS" | sudo chpasswd

# Mở port firewall (nếu cần)
sudo ufw allow $SOCKS_PORT/tcp

# Khởi động & enable dịch vụ
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable viefast-ossh
sudo systemctl start viefast-ossh
sudo systemctl restart danted
sudo systemctl enable danted

# === Hoàn tất ===
IP=$(curl -s ifconfig.me)
echo ""
echo "✅ ĐÃ CÀI ĐẶT THÀNH CÔNG!"
echo "🔌 SSH Tunnel SOCKS5: $IP:$SOCKS_PORT (no-auth)"
echo "🧩 Danted SOCKS5 có username/password:"
echo "     👉 Server: $IP"
echo "     👉 Port: $SOCKS_PORT"
echo "     👉 Username: $AUTH_USER"
echo "     👉 Password: $AUTH_PASS"
echo ""
echo "📱 Dùng ngay với Shadowrocket, V2RayNG, ProxyCap, v.v."
