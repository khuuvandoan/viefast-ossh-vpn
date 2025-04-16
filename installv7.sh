#!/bin/bash

echo "🔧 Cài đặt toàn bộ hệ thống VieFast VPN (OSSH + SOCKS5 có mật khẩu)"

# === Nhập thông tin SSH Tunnel ===
read -p "🌐 Nhập SSH host (IP hoặc domain): " SSH_HOST
read -p "👤 Nhập SSH username [vpnuser]: " SSH_USER
SSH_USER=${SSH_USER:-vpnuser}
read -s -p "🔐 Nhập SSH password: " SSH_PASSWORD
echo ""

# === Cấu hình mặc định ===
SSH_PORT=22
SOCKS_PORT=1080
AUTH_USER="vfastvpn"
AUTH_PASS="vpn123"

# === Cài đặt gói cần thiết ===
echo "📦 Cài đặt autossh, sshpass, danted..."
sudo apt update && sudo apt install -y autossh sshpass danted curl ufw

# === Lấy đường dẫn tuyệt đối ===
AUTOSSH_BIN=$(which autossh)
SSHPASS_BIN=$(which sshpass)

# === Tạo thư mục & script autossh ===
mkdir -p ~/viefast-ossh
cat <<EOF > ~/viefast-ossh/ssh-tunnel.sh
#!/bin/bash
$SSHPASS_BIN -p "$SSH_PASSWORD" $AUTOSSH_BIN -M 0 -N -D 0.0.0.0:$SOCKS_PORT -p $SSH_PORT $SSH_USER@$SSH_HOST
EOF

chmod +x ~/viefast-ossh/ssh-tunnel.sh

# === Tạo systemd service cho OSSH ===
sudo tee /etc/systemd/system/viefast-ossh.service > /dev/null <<EOF
[Unit]
Description=VieFast OSSH SOCKS5 VPN
After=network.target

[Service]
ExecStart=/home/$USER/viefast-ossh/ssh-tunnel.sh
Restart=always
RestartSec=5
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# === Cấu hình Danted SOCKS5 có xác thực ===
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

# === Tạo user xác thực SOCKS5 ===
sudo useradd -M -s /usr/sbin/nologin $AUTH_USER || echo "👤 User đã tồn tại"
echo "$AUTH_USER:$AUTH_PASS" | sudo chpasswd

# === Mở port firewall (nếu có ufw) ===
sudo ufw allow $SOCKS_PORT/tcp || true

# === Khởi động và enable services ===
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable viefast-ossh
sudo systemctl restart viefast-ossh
sudo systemctl restart danted
sudo systemctl enable danted

# === Thông báo thành công ===
IP=$(curl -s ifconfig.me)
echo ""
echo "✅ HỆ THỐNG VPN ĐÃ SẴN SÀNG!"
echo "🔌 SSH Tunnel SOCKS5 (no-auth):"
echo "    👉 Host: $IP"
echo "    👉 Port: $SOCKS_PORT"
echo ""
echo "🧩 SOCKS5 CÓ MẬT KHẨU (Danted):"
echo "    👉 Host: $IP"
echo "    👉 Port: $SOCKS_PORT"
echo "    👉 Username: $AUTH_USER"
echo "    👉 Password: $AUTH_PASS"
echo ""
echo "📱 Sử dụng ngay với Shadowrocket, V2RayNG, ProxyDroid..."
