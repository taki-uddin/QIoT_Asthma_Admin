import 'package:fluro/fluro.dart';
import 'package:qiot_admin/main.dart';
import 'package:qiot_admin/screens/dashboard_screen/dashboard_screen.dart';
import 'package:qiot_admin/screens/authentication_screens/signin_screen.dart';
import 'package:qiot_admin/screens/user_details/user_details.dart';

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
        return DashboardScreen(
          router: router,
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
          // Handle the case where userId is null
          return const SigninScreen(); // or any other fallback screen
        }
        return UserDetails(
          userId: userId,
        );
      },
    ),
  );
}
