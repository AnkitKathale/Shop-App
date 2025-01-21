import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart' as ca;

class CartScreen extends StatelessWidget {
  static const chatscreen = '/chatscreen';
  @override
  Widget build(BuildContext context) {
    final cartContainer = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                        '\₹${cartContainer.totalamount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .color,
                        )),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OrderItem(cartContainer: cartContainer),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) => ca.CartItem(
                id: cartContainer.items.values.toList()[index].id,
                productId: cartContainer.items.keys.toList()[index],
                title: cartContainer.items.values.toList()[index].title,
                price: cartContainer.items.values.toList()[index].price,
                quantity: cartContainer.items.values.toList()[index].quantity,
              ),
              itemCount: cartContainer.items.length,
            ),
          )
        ],
      ),
    );
  }
}

class OrderItem extends StatefulWidget {
  const OrderItem({
    Key? key,
    required this.cartContainer,
  }) : super(key: key);

  final Cart cartContainer;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
      onPressed: (widget.cartContainer.totalamount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Order>(context, listen: false).add(
                  widget.cartContainer.items.values.toList(),
                  widget.cartContainer.totalamount);
              setState(() {
                _isLoading = false;
              });

              widget.cartContainer.clear();
            },
    );
  }
}
