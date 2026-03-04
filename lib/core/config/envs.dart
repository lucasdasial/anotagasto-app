// coverage:ignore-file
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Envs {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000';
}
