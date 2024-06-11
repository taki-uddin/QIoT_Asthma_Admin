import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/routes/web_router_provider.dart';
import 'package:qiot_admin/routes/web_routes.dart';

late bool _loginState;

void main() async {
  final router = FluroRouter();
  // Check login state from session storage
  String? loginState = await SessionStorageHelpers.getStorage('loginState');
  _loginState = loginState != null && loginState == 'true';
  defineRoutes(router);
  runApp(
    WebRouterProvider(
      router: router,
      child: Main(router: router),
    ),
  );
}

class Main extends StatefulWidget {
  final FluroRouter router;
  const Main({super.key, required this.router});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QIoT Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: widget.router.generator,
      initialRoute: _loginState ? '/dashboard' : '/',
    );
  }
}
