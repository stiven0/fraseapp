enum Errors {
  failedConnection,
  serverError,
  none
}

class CustomError implements Exception {
  final Errors message;

  CustomError(this.message);
}