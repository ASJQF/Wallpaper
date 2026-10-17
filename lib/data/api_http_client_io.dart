import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createApiClient() {
  final io = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  return IOClient(io);
}
