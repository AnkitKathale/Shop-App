import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import 'product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final showFav;
  ProductsGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFav ? productData.favourite : productData.item;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10),
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: products[index],
          child: ProductItem(),
        );
      },
      itemCount: products.length,
    );
  }
}
