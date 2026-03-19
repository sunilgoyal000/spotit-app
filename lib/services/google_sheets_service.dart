import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSheetsService {
  static const String scriptUrl =
      "https://script.google.com/macros/s/AKfycbydP-RrFI4ZUIVQjf70uwtL7wduZfSJ_AFSYZD4h2vzM2EpbSG_2XRrrFVA61taH4279Q/exec";

  static Future<void> submitReport({
    required String name,
    required String phone,
    required bool sharePhone,
    required String category,
    required String description,
    required String location,
  }) async {
    final response = await http.post(
      Uri.parse(scriptUrl),
      body: {
        'name': name,
        'phone': phone,
        'sharePhone': sharePhone ? "Yes" : "No",
        'category': category,
        'description': description,
        'location': location,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Server error");
    }

    final result = json.decode(response.body);
    if (result['status'] != 'success') {
      throw Exception("Backend error");
    }
  }
}
