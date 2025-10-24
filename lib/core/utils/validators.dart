class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class Either<L, R> {
  final L? left;
  final R? right;
  
  Either.left(this.left) : right = null;
  Either.right(this.right) : left = null;
  
  bool isLeft() => left != null;
  bool isRight() => right != null;
}