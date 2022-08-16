
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Empty extends StatefulWidget {
  static final route = GoRoute(
    path: 'Empty',
    name: (Empty).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => Empty(),
  );

  const Empty({Key? key}) : super(key: key);

  @override
  State<Empty> createState() => _EmptyState();
}

class _EmptyState extends State<Empty> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('در حال اماده سازی'),
      ),
    );
  }
}
