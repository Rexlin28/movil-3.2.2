import 'package:http/http.dart' as http;

class Api {
  static Future<String> getSensor(String sensor) async {
    try {
      http.Client cliente = http.Client();
      Uri url = Uri.parse("http://192.168.137.100/$sensor");
      http.Response respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        return respuesta.body;
      } else {
        return "Error de sensor: ${respuesta.statusCode}";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }
}
