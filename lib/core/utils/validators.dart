class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صالح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن لا تقل عن 8 خانات';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    if (value.trim().length < 3) {
      return 'الاسم الكامل يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال اسم المستخدم';
    }
    final usernameTrim = value.trim().replaceAll('@', '');
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegExp.hasMatch(usernameTrim)) {
      return 'اسم المستخدم يمكن أن يحتوي فقط على أحرف وأرقام وشرطة سفلية';
    }
    return null;
  }
}
