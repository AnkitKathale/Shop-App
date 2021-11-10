import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _item = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._item);
  Product findbyid(String id) {
    return _item.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favourite {
    return _item.where((product) => product.isFavourite).toList();
  }

  List<Product> get item {
    return [..._item];
  }

  Future<void> fetchandSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shop-app-f4d98-default-rtdb.firebaseio.com/product.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body);
      if (extractedData == null || extractedData['error'] != null) {
        _item = [];
        notifyListeners();
        print(extractedData);
        return;
      }
      url = Uri.parse(
          'https://shop-app-f4d98-default-rtdb.firebaseio.com/userFavourite/$userId.json?auth=$authToken');
      final favResponse = await http.get(url);
      final extractedfavResponse = json.decode(favResponse.body);

      List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavourite: extractedfavResponse == null
                ? false
                : extractedfavResponse[prodId] ?? false,
            imageUrl: prodData['imageUrl']));
      });
      _item = loadedProduct;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> add(Product product) async {
    final url = Uri.parse(
        'https://shop-app-f4d98-default-rtdb.firebaseio.com/product.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          }));
      final addproduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _item.add(addproduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> update(String id, Product newproduct) async {
    var productIndex = _item.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-f4d98-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newproduct.title,
            'description': newproduct.description,
            'imageUrl': newproduct.imageUrl,
            'price': newproduct.price
          }));
      _item[productIndex] = newproduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> delete(String id) async {
    final url = Uri.parse(
        'https://shop-app-f4d98-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken');
    final existingProductIndex = _item.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _item[existingProductIndex];

    _item.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _item.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
