import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const userproductscreen = '/userproductscreen';

  Future<void> refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchandSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productdata = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Yours Product'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                    EditProductScreen.editproductscreen,
                    arguments: false);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: refreshProduct(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => refreshProduct(context),
                    child: Consumer<Products>(
                      builder: (ctx, productdata, _) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: productdata.item.length,
                            itemBuilder: (_, index) {
                              return Column(
                                children: [
                                  UserProductItem(
                                      id: productdata.item[index].id,
                                      title: productdata.item[index].title,
                                      imgUrl: productdata.item[index].imageUrl),
                                  Divider(),
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }
}
