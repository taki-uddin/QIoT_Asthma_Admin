import 'package:fluro/fluro.dart';
import 'package:qiot_admin/screens/dashboard_screen.dart';
import 'package:qiot_admin/screens/signin_screen.dart';
import 'package:qiot_admin/screens/user_details.dart';

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
        final String userId = params['id']![0];
        return UserDetails(
          userId: userId,
        );
      },
    ),
  );
}
