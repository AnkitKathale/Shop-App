import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/ord_item.dart';

class OrderScreen extends StatefulWidget {
  static const orderscreen = '/orderscreen';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future? getOrder;
  Future getOrderFunction() {
    return Provider.of<Order>(context, listen: false).fetchandSetOrder();
  }

  @override
  void initState() {
    getOrder = getOrderFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: getOrder,
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapShot.error != null) {
                return Center(
                  child: Text('Oops! An error occured'),
                );
              } else {
                return ListView.builder(
                  itemCount: orderData.order.length,
                  itemBuilder: (ctx, index) => OrdItem(orderData.order[index]),
                );
              }
            }
          }),
    );
  }
}
