class UserData {
  static String name = ''; // Initialize name as an empty string
  static String email = ''; // Initialize email as an empty string
  static String password = ''; // Initialize password as an empty string

  // Method to update just the name
  static void updateName(String newName) {
    name = newName;
  }

  // Method to update just the email
  static void updateEmail(String newEmail) {
    email = newEmail;
  }

  // Method to update just the password
  static void updatePassword(String newPassword) {
    password = newPassword;
  }

  // Method to update user data (name, email, password)
  static void updateUserData(String newName, String newEmail, String newPassword) {
    name = newName;
    email = newEmail;
    password = newPassword;
  }

  // Method to clear all user data
  static void clearUserData() {
    name = '';
    email = '';
    password = '';
  }
}
