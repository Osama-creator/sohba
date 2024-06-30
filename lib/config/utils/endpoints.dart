abstract class ApiEndPoints {
  // ! dashboard production
  static const String host = 'm';

  static const String api = '$host/api';

  // ! auth
  static const String login = '/auth/me';
  // ! leaves
  static const String newLeave = '/leaves/create';
  static const String getLeaves = '/leaves/getAll';
}
