#!/bin/bash

# ====== THÔNG TIN CẤU HÌNH SSH ==========
SSH_USER="root"
SSH_HOST="103.77.247.208"
SSH_PORT=22
LOCAL_SOCKS_PORT=1080
# ========================================

echo "📦 Đang cài đặt VieFast OSSH SOCKS5 VPN..."

# Cài autossh nếu chưa có
sudo apt update && sudo apt install -y autossh

# Tạo thư mục làm việc
mkdir -p ~/viefast-ossh
cd ~/viefast-ossh

# Tạo script khởi chạy autossh tunnel
cat <<EOF > start-ossh.sh
#!/bin/bash
autossh -M 0 -f -N -D 0.0.0.0:$LOCAL_SOCKS_PORT -p $SSH_PORT $SSH_USER@$SSH_HOST
EOF

chmod +x start-ossh.sh

# Tạo systemd service để tự động chạy
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

# Kích hoạt dịch vụ
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable viefast-ossh
sudo systemctl start viefast-ossh

echo "✅ Cài đặt hoàn tất!"
echo "🔌 SOCKS5 proxy đang lắng nghe tại: 0.0.0.0:$LOCAL_SOCKS_PORT"
echo "📱 Bạn có thể dùng với V2RayNG, Shadowrocket hoặc ProxyDroid."
