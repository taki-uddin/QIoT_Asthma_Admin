import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:qiot_admin/helpers/session_storage_helpers.dart';
import 'package:qiot_admin/routes/web_router_provider.dart';
import 'package:qiot_admin/routes/web_routes.dart';
import 'package:qiot_admin/services/auth_session.dart';
import 'package:qiot_admin/services/token_refresh_service.dart';

String deviceType = 'web';
final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SessionStorageHelpers.getStorage('loginState'); // triggers session migration

  final router = FluroRouter();
  defineRoutes(router);

  final hasValidSession = await AuthSession.ensureValidSession();

  runApp(
    WebRouterProvider(
      router: router,
      child: Main(router: router, initialRoute: hasValidSession ? '/dashboard' : '/'),
    ),
  );
}

class Main extends StatefulWidget {
  final FluroRouter router;
  final String initialRoute;

  const Main({
    super.key,
    required this.router,
    required this.initialRoute,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late TokenRefreshService _tokenRefreshService;

  @override
  void initState() {
    super.initState();
    _tokenRefreshService = TokenRefreshService();
    _initializeTokenRefreshService();
  }

  Future<void> _initializeTokenRefreshService() async {
    if (!await AuthSession.hasStoredCredentials()) return;
    _tokenRefreshService.initialize(null, deviceType);
    _tokenRefreshService.startTokenRefreshTimer();
  }

  @override
  void dispose() {
    _tokenRefreshService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'QIoT Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: widget.router.generator,
      initialRoute: widget.initialRoute,
    );
  }
}
