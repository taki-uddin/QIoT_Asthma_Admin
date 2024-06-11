import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class WebRouterProvider extends StatelessWidget {
  final Widget child;
  final FluroRouter router;

  const WebRouterProvider({
    Key? key,
    required this.child,
    required this.router,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
