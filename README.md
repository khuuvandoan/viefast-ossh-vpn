# VieFast OSSH VPN 🛡️

**VieFast OSSH VPN** là giải pháp VPN siêu nhẹ, bảo mật cao sử dụng giao thức SSH để tạo kết nối SOCKS5 proxy, tương thích với Clash Meta và hầu hết các ứng dụng hiện nay.  
Thích hợp cho các mạng bị chặn VPN thông thường (OpenVPN, WireGuard...) hoặc cần thiết lập nhanh không cần cấu hình phức tạp.

---

## 🚀 Tính năng nổi bật

- Tạo VPN qua SSH tunnel (OSSH) – không cần cài đặt VPN server
- Tương thích Clash Meta (Linux, macOS, Android, Windows)
- Kết nối SOCKS5 tự động qua SSH
- Khởi động cùng hệ thống với systemd service
- Cài đặt nhanh chóng chỉ với 1 dòng lệnh

---

## 📦 Cài đặt nhanh (trên Ubuntu)

```bash
bash <(curl -sSL https://raw.githubusercontent.com/<your-username>/viefast-ossh-vpn/main/install.sh)
