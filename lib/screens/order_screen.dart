import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Order;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = 'order_screen';

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Order>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
          itemCount: orderData.orders.length,
          itemBuilder: (ctx, index) => OrderItem(orderData.orders[index])),
    );
  }
}
