import 'package:flutter/material.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';
import 'providers/products.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products('', '', []),
          update: (ctx, auth, previousProduct) => Products(auth.token,
              auth.userId, previousProduct == null ? [] : previousProduct.item),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (ctx) => Order('', '', []),
          update: (ctx, auth, previousOrder) => Order(auth.token, auth.userId,
              previousOrder == null ? [] : previousOrder.order),
        )
      ],
      child: Consumer<Auth>(
        builder: (
          ctx,
          auth,
          _,
        ) =>
            MaterialApp(
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
          ),
          // initialRoute: '/',
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultdata) =>
                      authResultdata.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            // '/': (ctx) => AuthScreen(),
            // ProductsOverviewScreen.productOverviewscreen: (ctx) =>
            //     ProductsOverviewScreen(),
            ProductDetailScreen.productdetailscreen: (ctx) =>
                ProductDetailScreen(),
            CartScreen.chatscreen: (ctx) => CartScreen(),
            OrderScreen.orderscreen: (ctx) => OrderScreen(),
            UserProductScreen.userproductscreen: (ctx) => UserProductScreen(),
            EditProductScreen.editproductscreen: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
