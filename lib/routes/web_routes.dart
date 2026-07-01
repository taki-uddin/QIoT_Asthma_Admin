import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/screens/dashboard_screen/dashboard_screen.dart';
import 'package:qiot_admin/screens/authentication_screens/signin_screen.dart';
import 'package:qiot_admin/screens/user_details/user_details.dart';
import 'package:qiot_admin/widgets/auth_guard.dart';

void defineRoutes(FluroRouter router) {
  router.define(
    '/',
    handler: Handler(
      handlerFunc: (context, params) {
        return const SigninScreen();
      },
    ),
  );
  router.define(
    '/dashboard',
    handler: Handler(
      handlerFunc: (context, params) {
        int initialTab = 0;
        if (context != null) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map && args['initialTab'] is int) {
            initialTab = args['initialTab'] as int;
          }
        }
        return AuthGuard(
          child: DashboardScreen(
            router: router,
            initialTab: initialTab,
          ),
        );
      },
    ),
  );
  router.define(
    '/usersdetails/:id',
    handler: Handler(
      handlerFunc: (context, params) {
        final String? userId = params['id']?.first;
        logger.d('userId: $userId');
        if (userId == null) {
          return const SigninScreen();
        }
        return AuthGuard(
          child: UserDetails(
            userId: userId,
          ),
        );
      },
    ),
  );
}
