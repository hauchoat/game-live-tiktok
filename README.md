# Mèo Săn Vàng

Game endless runner 3D dành cho TikTok LIVE. Server Node.js/Express giữ trạng thái game, Socket.IO đồng bộ màn LIVE và trang điều khiển, Vite + React + Three.js dựng cảnh. Quà LIVE đi qua `tiktok-live-connector`; bot tự chạy và tự mua nâng cấp. Khi CAT hết mạng, vòng chơi kết thúc rồi tự mở vòng mới.

Nhân vật, nhà cửa, chướng ngại vật, biểu tượng và âm thanh được dựng bằng hình khối/SVG/Web Audio trong dự án; game không tải hay sao chép tài nguyên từ game hoặc nền tảng khác.

## Yêu cầu

- Node.js 20 trở lên
- npm

## Chạy thử, không cần LIVE thật

```bash
npm install
npm run mock
```

Mở `http://localhost:5173/control`. Vào **Quà & hàng đợi** để gửi quà mô phỏng; có thể mở `/live` để xem màn hình game. Chế độ mock không kết nối tài khoản TikTok thật. Trên Windows có thể chạy `RUN.bat`.

## Chạy với TikTok LIVE

Chạy môi trường phát triển:

```bash
npm run dev
```

Hoặc dựng production rồi chạy server:

```bash
npm run build
npm start
```

Mở trang điều khiển, nhập username tài khoản đang LIVE và chọn **Kết nối LIVE**. Kết nối cần tài khoản đang phát; `tiktok-live-connector` là thư viện bên thứ ba và luồng kết nối có thể thay đổi theo TikTok. Nếu thư viện yêu cầu sign API key, đặt biến môi trường `TIKTOK_SIGN_API_KEY` trước khi chạy server.

## OBS

Thêm Browser Source với URL `http://localhost:3001/live` khi chạy production, hoặc `http://localhost:5173/live` khi chạy dev/mock. Màn hình có tỷ lệ dọc 9:16, nền trong suốt; bật âm thanh bằng `?sound=1` nếu cần.

## Kiểm tra

```bash
npm test
npm run build
npm run benchmark
```

`gifts.config.json` chứa rule quà, vật cản và bot; `map.config.json` định nghĩa các đoạn đường. Có thể chỉnh các thông số được hỗ trợ trong trang điều khiển, sau đó lưu để áp dụng.

## Logic server

Mô phỏng dùng bước cố định `1/30` giây và đồng hồ đơn điệu để bù các callback bị trễ. Mỗi callback xử lý tối đa 30 bước, giữ phần thời gian còn dư cho callback tiếp theo. Render và việc đóng hoặc kết nối lại client không điều khiển thời gian mô phỏng. State công khai có `distance` (mét, đồng nhất với `cat.z`) và `roundSeconds`.

Bot nhìn trước 15–20m, ưu tiên làn trống an toàn gần nhất; vàng quyết định khi các làn cách đều. Nếu không có làn trống an toàn, bot xét nhảy/trượt theo loại vật cản. `bot.dramaRate` điều chỉnh xác suất chọn đường đi sát vật cản trong các phương án dự đoán an toàn; đặt `0` để tắt. Chính sách mua là hồi mạng khẩn cấp → khiên → hồi tới 4 mạng → nam châm → tốc độ có dự phòng vàng → mạng còn thiếu. Các nâng cấp đã đạt trần được bỏ qua; giá mỗi cấp bằng `baseCost + level × costStep`.

Quà chuỗi chỉ vào hàng đợi ở `repeatEnd`; sự kiện cuối có cùng ID chuỗi/tin nhắn không được tính lại. `repeatCount` hiển thị số quà trong chuỗi, không nhân số vật cản vượt giới hạn mỗi sự kiện. Người nhận điểm là người tặng quà được chấp nhận cuối cùng trước khi CAT bị bắt, kể cả khi quà cũ vẫn nằm trong hàng đợi. Một vòng chỉ cộng điểm một lần; bẫy tự nhiên khi chưa có người tặng không tạo điểm cho tài khoản giả. Vòng mới bắt đầu sau đúng 150 tick (5 giây), giữ vàng, cấp nâng cấp và bảng điểm.

Checklist và vị trí kiểm chứng: `reports/server-checklist.md`. `npm run soak` chạy 10 vòng tự nhiên với quà mô phỏng và ghi kết quả vào `reports/soak.json`; không cần kết nối TikTok thật.

## Đồ họa client

CAT là mèo cam mắt to, đuôi cong, mặc áo khoác xanh dương và mang ba lô nhỏ. Toàn bộ nhân vật, vật cản và phố đèn lồng được dựng bằng hình khối; icon quà là SVG tự vẽ. Các phụ kiện phi hành gia/streamer vẫn giữ màu mèo cam và áo xanh. Cảnh có ba làn, camera sau CAT cố định, màu trời/đường đổi mỗi 500m và hỗ trợ nền OBS trong suốt.

Vật cản có `activeAtRoundSeconds` do server gửi: hiện cảnh báo sáng mờ trong một giây mô phỏng trước khi xuất hiện đầy đủ và có thể gây va chạm. Client dùng cùng thời gian server, nên kết nối lại không làm vật cản đang hoạt động nhấp nháy cảnh báo lại. Bot vẫn nhìn thấy các vật cản sắp kích hoạt để chuẩn bị né.

Client nội suy các snapshot 30 Hz để render mượt. Chuyển làn không cộng thêm một lớp easing vào chuyển động 0,15 giây của server; nhảy/trượt giữ thời lượng 0,48 giây. Vàng xoay, sáng khi tới gần, phát hạt và bay từ vị trí nhặt tới số đếm HUD. Xoay khi bị bắt dài 0,75 giây, rung camera nhẹ 0,3 giây; thông báo người bắt giữ ba giây, rồi bảng kết quả hiển thị trong phần đếm ngược còn lại. Hiệu ứng quà dài tối đa 0,7 giây; thẻ thông tin quà có thể giữ bốn giây để đọc.

Các phần tĩnh được gộp bằng vertex colors, vật cản dùng chung geometry, số vật cản/vàng/hạt hiển thị có giới hạn và độ phân giải tự giảm nếu FPS thấp liên tục. Không dùng texture cho cảnh 3D. Mục tiêu là tối đa 250 mesh, 60 FPS; kết quả đo trên máy kiểm thử nằm trong `reports/graphics.json`, ảnh trong `reports/graphics/`, đối chiếu yêu cầu trong `reports/client-checklist.md`.

Kiểm thử hình học nằm trong `npm test`. Chạy thêm `npm run check:graphics` để kiểm tra Chrome và đo FPS. Lệnh này cần Playwright và Chrome/Chromium trong môi trường kiểm thử; nếu Playwright được cài ở nơi khác, đặt `PLAYWRIGHT_MODULE_PATH` tới thư mục package đó. Có thể đặt `CHROME_PATH` để chọn trình duyệt. Bài kiểm tra mở server fixture riêng trên cổng tạm, dùng quà/state mô phỏng và không kết nối TikTok LIVE thật.
