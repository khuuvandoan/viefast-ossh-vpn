#!/bin/bash

echo "🔧 Cài đặt Danted SOCKS5 Proxy (có nhập thông tin cấu hình)"

# === Nhập thông tin người dùng ===
read -p "🌐 Nhập địa chỉ IP hoặc domain của server (dùng để hiển thị): " SERVER_IP
read -p "📦 Nhập cổng SOCKS5 muốn sử dụng [mặc định: 1080]: " SOCKS_PORT
SOCKS_PORT=${SOCKS_PORT:-1080}

read -p "👤 Nhập username SOCKS5 [mặc định: vfastvpn]: " SOCKS_USER
SOCKS_USER=${SOCKS_USER:-vfastvpn}

read -s -p "🔐 Nhập password SOCKS5 [mặc định: vpn123]: " SOCKS_PASS
SOCKS_PASS=${SOCKS_PASS:-vpn123}
echo ""

# === Cài đặt gói cần thiết ===
echo "📦 Đang cài đặt dante-server..."
sudo apt update
sudo apt install -y dante-server ufw curl

# === Tìm interface mạng ===
IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
echo "🌐 Interface mạng được sử dụng: $IFACE"

# === Tạo cấu hình Danted ===
echo "🛠️ Tạo file cấu hình Danted..."
sudo tee /etc/danted.conf > /dev/null <<EOF
logoutput: /var/log/danted.log
internal: $IFACE port = $SOCKS_PORT
external: $IFACE
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

# === Tạo user SOCKS5 ===
echo "👤 Tạo tài khoản SOCKS5..."
sudo useradd -M -s /usr/sbin/nologin $SOCKS_USER || echo "⚠️ User đã tồn tại"
echo "$SOCKS_USER:$SOCKS_PASS" | sudo chpasswd

# === Mở port firewall (nếu dùng UFW) ===
echo "🌍 Mở port $SOCKS_PORT trên tường lửa..."
sudo ufw allow $SOCKS_PORT/tcp || true

# === Khởi động dịch vụ ===
echo "🚀 Khởi động Danted SOCKS5..."
sudo systemctl enable danted
sudo systemctl restart danted

# === Kiểm tra và báo kết quả ===
echo ""
echo "✅ SOCKS5 proxy đã sẵn sàng!"
echo "🌐 Server: $SERVER_IP"
echo "🔌 Port: $SOCKS_PORT"
echo "👤 Username: $SOCKS_USER"
echo "🔐 Password: $SOCKS_PASS"
echo ""
echo "📱 Dùng ngay với Shadowrocket, V2RayNG hoặc bất kỳ ứng dụng hỗ trợ SOCKS5 có mật khẩu."
