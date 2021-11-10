import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:intl/intl.dart';

class OrdItem extends StatefulWidget {
  final OrderItem ordData;
  OrdItem(this.ordData);

  @override
  _OrdItemState createState() => _OrdItemState();
}

class _OrdItemState extends State<OrdItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('\₹${widget.ordData.totalprice.toStringAsFixed(2)}'),
            subtitle: Text(
                DateFormat('dd-MM-yyyy hh:mm').format(widget.ordData.date)),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more)),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.ordData.product.length * 20 + 10, 100),
              child: ListView(
                children: widget.ordData.product.map((prod) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prod.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${prod.quantity}x \₹${prod.price}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}
