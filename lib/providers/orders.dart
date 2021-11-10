import 'package:flutter/cupertino.dart';
import 'package:shop_app/providers/cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double totalprice;
  final List<CartItem> product;
  final DateTime date;

  OrderItem(
      {required this.id,
      required this.totalprice,
      required this.product,
      required this.date});
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get order {
    return [..._orders];
  }

  final String? authToken;
  final String? userId;

  Order(this.authToken, this.userId, this._orders);

  Future<void> fetchandSetOrder() async {
    var extractedData;
    final url = Uri.parse(
        'https://shop-app-f4d98-default-rtdb.firebaseio.com/order/$userId.json?auth=$authToken');
    final response = await http.get(url);

    List<OrderItem> orderitems = [];
    extractedData = json.decode(response.body);
    if (extractedData == null) {
      _orders = [];
      notifyListeners();
      return;
    }
    extractedData.forEach((ordId, orddata) {
      orderitems.add(OrderItem(
          id: ordId,
          totalprice: orddata['totalprice'],
          product: (orddata['product'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    quantity: item['quantity'],
                  ))
              .toList(),
          date: DateTime.parse(orddata['date'])));
    });
    _orders = orderitems.reversed.toList();
    notifyListeners();
  }

  Future<void> add(List<CartItem> cartprod, double amount) async {
    final url = Uri.parse(
        'https://shop-app-f4d98-default-rtdb.firebaseio.com/order/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'totalprice': amount,
          'date': timestamp.toIso8601String(),
          'product': cartprod
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'price': cp.price,
                    'quantity': cp.quantity
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            totalprice: amount,
            product: cartprod,
            date: timestamp));
    notifyListeners();
  }
}
