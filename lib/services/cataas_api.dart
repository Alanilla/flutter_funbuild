import 'dart:convert';
import 'package:http/http.dart' as http;

class CataasApi {
  static Future<List<String>> fetchCatImages({int count = 12}) async {
    final uri = Uri.parse('https://cataas.com/api/cats?limit=$count');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch cat data');
    }

    final List data = jsonDecode(res.body) as List;
    final validIds = data
        .where((e) => e is Map && e['_id'] != null && e['_id'].toString().isNotEmpty)
        .map((e) => e['_id'].toString())
        .toList();

    // fallback to random image endpoints
    if (validIds.isEmpty) {
      return List.generate(count, (i) {
        final cacheBuster = DateTime.now().millisecondsSinceEpoch + i;
        return 'https://cataas.com/cat?width=800&height=1000&random=$cacheBuster';
      });
    }

    return validIds
        .map((id) => 'https://cataas.com/cat/$id?width=800&height=1000')
        .toList();
  }
}
