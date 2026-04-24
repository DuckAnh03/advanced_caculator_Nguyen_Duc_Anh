
## Các Thành Phần Chính

### 1. Models (Mô Hình Dữ Liệu)

- CalculatorMode: Định nghĩa ba chế độ (Basic, Scientific, Programmer)
- CalculatorSettings: Lưu trữ cài đặt người dùng (giao diện, độ chính xác, v.v.)
- CalculationHistory: Mô hình mỗi mục trong lịch sử tính toán

### 2. Providers (Quản Lý Trạng Thái)

**CalculatorProvider**
- Quản lý: biểu thức, kết quả, lỗi, chế độ hiện tại
- Xử lý: nhập số, phép toán, tính toán, lịch sử
- Công việc: phân tích biểu thức, tính kết quả, lưu lịch sử

**ThemeProvider**
- Quản lý: chế độ sáng/tối
- Cung cấp: theme hiện tại cho toàn bộ ứng dụng

**HistoryProvider**
- Quản lý: danh sách lịch sử tính toán
- Công việc: thêm, xóa, lấy lịch sử

### 3. Services (Dịch Vụ)

**StorageService**
- Lưu trữ dữ liệu lịch sử và cài đặt vào thiết bị
- Tải dữ liệu từ thiết bị khi khởi động
- Xử lý: serialization/deserialization

### 4. Utils (Tiện Ích)

**ExpressionParser**
- Phân tích chuỗi biểu thức toán học
- Hỗ trợ: các phép toán cơ bản, hàm khoa học, số nguyên

**CalculatorLogic**
- Thực hiện tính toán
- Kiểm tra lỗi (chia cho 0, v.v.)

**Constants**
- Hằng số toàn cục (số Pi, e, v.v.)

## Luồng Dữ Liệu

1. Người dùng nhấn nút → CalculatorProvider nhận sự kiện
2. Provider cập nhật biểu thức hoặc tính toán kết quả
3. ExpressionParser phân tích biểu thức
4. CalculatorLogic thực hiện phép tính
5. Provider cập nhật UI thông qua ChangeNotifier
6. Khi nhấn "=", kết quả được lưu vào HistoryProvider
7. StorageService lưu lịch sử vào thiết bị

## State Management (Quản Lý Trạng Thái)

Ứng dụng sử dụng **Provider** package để quản lý trạng thái:

- MultiProvider ở main.dart cung cấp ba provider cho toàn bộ ứng dụng
- Mỗi provider là ChangeNotifier, khi trạng thái thay đổi sẽ thông báo cho các widget lắng nghe
- Consumer hoặc Selector được sử dụng để lắng nghe thay đổi trạng thái
- Lợi ích: tách biệt logic khỏi giao diện, dễ kiểm tra, dễ bảo trì

## Lớp Lưu Trữ

StorageService sử dụng SharedPreferences hoặc các phương pháp lưu trữ cục bộ khác:

- Lịch sử tính toán được lưu dưới dạng JSON
- Cài đặt được lưu dưới dạng key-value
- Dữ liệu được tải khi ứng dụng khởi động
- Dữ liệu được lưu ngay sau khi người dùng thực hiện hành động

## Luồng Khởi Động

1. main() gọi StorageService.init() - nạp dữ liệu từ thiết bị
2. AdvancedCalculatorApp xây dựng MultiProvider với ba provider
3. ThemeProvider cung cấp theme đã lưu
4. CalculatorProvider khởi tạo trạng thái ban đầu
5. HistoryProvider tải lịch sử từ StorageService
6. Ứng dụng hiển thị CalculatorScreen

## Thiết Kế Giao Diện

- Sử dụng Flutter Material Design
- Hỗ trợ chế độ sáng và tối (Light/Dark theme)
- Bố cục responsive tùy theo kích thước màn hình
- Button Grid hiển thị các nút bấm theo chế độ hiện tại