import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart' as badge;
import 'package:shop_app/widgets/products_grid.dart';
import 'package:provider/provider.dart';

enum FilteredOptions {
  Favourite,
  ShowAll,
}

class ProductsOverviewScreen extends StatefulWidget {
  // static const productOverviewscreen = '/productoverviewscreen';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var showOnlyFavourite = false;
  // var _isinit = true;
  Future? getProducts;
  Future getProductsFunction() {
    return Provider.of<Products>(context, listen: false).fetchandSetProducts();
  }

  @override
  void initState() {
    getProducts = getProductsFunction();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_isinit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(context)
  //         .fetchandSetProducts()
  //         .then((_) => _isLoading = false);
  //   }
  //   _isinit = false;
  // }

  @override
  Widget build(BuildContext context) {
    final cartContainer = Provider.of<Cart>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('My Shop'),
          actions: [
            PopupMenuButton(
              onSelected: (select) {
                setState(() {
                  if (select == FilteredOptions.Favourite) {
                    showOnlyFavourite = true;
                  } else {
                    showOnlyFavourite = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) {
                return [
                  PopupMenuItem(
                    child: Text('Your Favourites'),
                    value: FilteredOptions.Favourite,
                  ),
                  PopupMenuItem(
                    child: Text('Show All'),
                    value: FilteredOptions.ShowAll,
                  )
                ];
              },
            ),
            Badge(
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.chatscreen);
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    )),
                label: Text(cartContainer.itemCount.toString()))
          ],
        ),
        body: FutureBuilder(
            future: getProducts,
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapshot.error != null) {
                  return Center(
                    child: Text('Oops! An error occured'),
                  );
                } else {
                  return ProductsGrid(showOnlyFavourite);
                }
              }
            }));
  }
}
