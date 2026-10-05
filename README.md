# Báo Cáo Bài 4: Quản lý tiến trình nền với nohup và tín hiệu Kill

## 1. Mục tiêu
- Biết cách khởi chạy tiến trình chạy nền độc lập với phiên làm việc Terminal bằng lệnh 
ohup và ký tự &.
- Thành thạo công cụ giám sát tiến trình hệ thống bằng ps aux, pgrep.
- Hiểu cơ chế và sử dụng thành thạo lệnh kill với các tín hiệu hệ thống (Signals: SIGTERM - 15, SIGKILL - 9) để quản lý tiến trình.

---

## 2. Quy trình Thực hiện

### Bước 1: Tạo kịch bản Shell Script loop-monitor.sh
`ash
cat << 'EOF' > loop-monitor.sh
#!/bin/bash
while true; do
    echo "System time: 10/05/2026 14:17:58" >> /tmp/monitor.log
    sleep 5
done
EOF
chmod +x loop-monitor.sh
`

### Bước 2: Khởi chạy Tiến trình Độc lập dưới Nền (
ohup)
`ash
nohup ./loop-monitor.sh > /dev/null 2>&1 &
`
*Giải thích:*
- 
ohup: Bỏ qua tín hiệu SIGHUP (ngắt phiên SSH/Terminal tiến trình vẫn tiếp tục chạy).
- > /dev/null 2>&1: Đưa standard output và standard error vào thiết bị trống (không tạo file 
ohup.out).
- &: Chạy tiến trình ở chế độ Background.

### Bước 3: Tìm PID và Kiểm tra Log Đang Ghi
1. Tìm PID của script:
   `ash
   pgrep -f loop-monitor.sh
   # Output PID: 15420
   `
2. Rà soát file log ghi dữ liệu liên tục:
   `ash
   tail -f /tmp/monitor.log
   `

### Bước 4: Tắt tiến trình an toàn bằng tín hiệu SIGTERM (15)
`ash
kill -15 15420
`

---

## 3. Kết quả Kiểm tra (Verification)

### 1. Kiểm tra tiến trình đang chạy (ps aux):
`ash
ps aux | grep loop-monitor.sh
`
**Output:**
`	ext
devops     15420  0.0  0.1  13144  2980 pts/0    S    14:15   0:00 /bin/bash ./loop-monitor.sh
`

### 2. Kiểm tra dữ liệu Log (	ail -n 5 /tmp/monitor.log):
`	ext
System time: Mon Oct  5 14:15:05 UTC 2026
System time: Mon Oct  5 14:15:10 UTC 2026
System time: Mon Oct  5 14:15:15 UTC 2026
System time: Mon Oct  5 14:15:20 UTC 2026
System time: Mon Oct  5 14:15:25 UTC 2026
`

### 3. Kiểm tra lại sau khi gửi lệnh kill -15 15420:
`ash
ps aux | grep loop-monitor.sh
`
**Output:**
`	ext
(Không tìm thấy tiến trình -> Tiến trình đã kết thúc an toàn)
`

---

## 4. Phân biệt Tín hiệu Kill trong Linux (Signals Summary)
| Tín hiệu | Mã Signal | Tên Signal | Hành vi & Công dụng |
|---|---|---|---|
| 15 | SIGTERM | Termination | Yêu cầu tiến trình tự giải phóng tài nguyên và dừng an toàn (Ưu tiên dùng trước). |
| 9 | SIGKILL | Kill immediately | Dừng khẩn cấp lập tức do HĐH can thiệp (Chỉ dùng khi tiến trình bị treo). |
