import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the API base URL (host + port), loaded from the `.env` file
/// at runtime via [flutter_dotenv]. Keeping it out of source means the
/// backend address never appears in version control.
///
/// - Android emulator: set API_BASE_URL to use 10.0.2.2 instead of localhost.
/// - Physical device: use the host machine's LAN IP.
final baseUrlProvider = Provider<String>((ref) {
  final url = dotenv.env['API_BASE_URL'];
  if (url == null || url.isEmpty) {
    throw StateError('API_BASE_URL is not set in .env');
  }
  return url;
});
