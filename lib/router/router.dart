import 'package:auto_route/auto_route.dart';

import 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        //HomeScreen is generated as HomeRoute because
        //of the replaceInRouteName property
        AutoRoute(
          initial: true,
          path: '/login',
          page: LoginPage.page,
        ),
        AutoRoute(
          path: '/navbar',
          page: NavBarPage.page,
        ),
        AutoRoute(
          path: '/logout',
          page: LogoutPage.page,
        ),

        AutoRoute(
          path: '/',
          page: MytaskPage.page,
        ),
      ];
}
