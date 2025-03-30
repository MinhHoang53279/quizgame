class UserData {
  // Danh sách lưu tạm thời thông tin người dùng trong RAM
  static List<Map<String, String>> users = [];

  // Thêm người dùng mới (gọi khi đăng ký)
  static void addUser(String username, String email, String password) {
    users.add({
      'username': username,
      'email': email,
      'password': password,
    }); // Dữ liệu nhập từ form sẽ được lưu vào danh sách này
  }

  // Kiểm tra đăng nhập (so khớp email + password)
  static bool validateUser(String email, String password) {
    for (var user in users) {
      if (user['email'] == email && user['password'] == password) {
        return true; // Đúng thông tin => đăng nhập thành công
      }
    }
    return false; // Sai thông tin => báo lỗi
  }
}
