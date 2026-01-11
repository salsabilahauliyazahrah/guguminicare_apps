class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    // Optional: add more password rules
    // final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    // final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    // final hasDigits = RegExp(r'\d').hasMatch(value);
    // final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(
      r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
    );
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    // Indonesian phone number validation (optional)
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Phone number must be 10-15 digits';
    }
    
    return null;
  }

  static String? validateRequired(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, {String? field}) {
    if (value == null || value.length < minLength) {
      final fieldName = field ?? 'This field';
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, {String? field}) {
    if (value != null && value.length > maxLength) {
      final fieldName = field ?? 'This field';
      return '$fieldName must be maximum $maxLength characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? validateNumber(String? value, {String field = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$field is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$field must be a valid number';
    }
    
    if (number <= 0) {
      return '$field must be greater than 0';
    }
    
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = double.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age <= 0) {
      return 'Age must be greater than 0';
    }
    
    if (age > 50) {
      return 'Age seems too high';
    }
    
    return null;
  }
}