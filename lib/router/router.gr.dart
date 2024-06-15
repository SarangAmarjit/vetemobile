// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:geotagcameraapp/pages/loginpage.dart' as _i1;
import 'package:geotagcameraapp/pages/logoutpage.dart' as _i2;
import 'package:geotagcameraapp/pages/navigationpage.dart' as _i3;

abstract class $AppRouter extends _i4.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i4.PageFactory> pagesMap = {
    LoginPage.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.LoginPage(),
      );
    },
    LogoutPage.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.LogoutPage(),
      );
    },
    NavBarPage.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.NavBarPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.LoginPage]
class LoginPage extends _i4.PageRouteInfo<void> {
  const LoginPage({List<_i4.PageRouteInfo>? children})
      : super(
          LoginPage.name,
          initialChildren: children,
        );

  static const String name = 'LoginPage';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i2.LogoutPage]
class LogoutPage extends _i4.PageRouteInfo<void> {
  const LogoutPage({List<_i4.PageRouteInfo>? children})
      : super(
          LogoutPage.name,
          initialChildren: children,
        );

  static const String name = 'LogoutPage';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i3.NavBarPage]
class NavBarPage extends _i4.PageRouteInfo<void> {
  const NavBarPage({List<_i4.PageRouteInfo>? children})
      : super(
          NavBarPage.name,
          initialChildren: children,
        );

  static const String name = 'NavBarPage';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}
