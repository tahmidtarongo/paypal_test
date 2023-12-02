import 'dart:convert';

import 'package:http_auth/http_auth.dart';
import 'package:http/http.dart' as http;

import 'create_paypal_order_model.dart';

class PayPal {
  String clientId = 'AfFH5vqEHvqDLnwuXX814N_1VKv9F-tYhWWmME9yYzQM7BRovzdPJGFH4EUjLNJtV2FJnH560TaWYnQd';
  String clientS = 'EPPyNfLe1vnK7q_D-kAok0CVA88nayZOWcERLY_AfNt2CXCeCZycD75iWZyPiRBr2P8dV3TSn-G7MCop';

  Future<String> getAccessToken() async {
    var client = BasicAuthClient(clientId, clientS);
    var response = await client.post(Uri.parse('https://api.sandbox.paypal.com/v1/oauth2/token?grant_type=client_credentials'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["access_token"];
    } else {
      return 'Not Found';
    }
  }

  Future<String> getPaymentUrl() async {
    Map<String, dynamic> transaction = {
      "intent": "CAPTURE",
      "purchase_units": [
        {
          "amount": {
            "currency_code": "USD",
            "value": 500,
          }
        }
      ],
      "application_context": {"return_url": "${Uri.base.toString()}success", "cancel_url": '${Uri.base.toString()}/cancel'}
    };
    var token = await getAccessToken();
    var response = await http.post(Uri.parse('https://api.sandbox.paypal.com/v2/checkout/orders'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(transaction));
    print(response.statusCode);
    var data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      var decodedData = CreatePaypalOrderModel.fromJson(data);
      String url = decodedData.links![1].href.toString();
      return url;
    }
    return '${Uri.base.toString()}/cancel';
  }
}
