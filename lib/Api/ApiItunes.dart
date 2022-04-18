import 'dart:convert';

import 'package:audio_player/Api/BaseUrl.dart';
import 'package:audio_player/Api/HeaderApi.dart';
import 'package:http/http.dart';

class ApiItunes {
  Client client = Client();
  static const String Url_search = "search?term=";

  Future<String> AmbilLagu(String artis) async {
    try {
      final response = await client
          .get(
              Uri.parse(BasedUrl().based_url +
                  Url_search +
                  artis.replaceAll(' ', '+')),
              headers: HeaderApi().DefaultHeaders)
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          return null;
        },
      );
      if (response.statusCode == 200) {
        String result = response.body.toString();
        return result;
      } else {
        return response.body.toString();
      }
    } catch (e) {
      return null;
    }
  }
}
