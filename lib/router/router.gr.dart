// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:geotagcameraapp/pages/loginpage.dart' as _i1;
import 'package:geotagcameraapp/pages/logoutpage.dart' as _i2;
import 'package:geotagcameraapp/pages/mytaskpage.dart' as _i3;
import 'package:geotagcameraapp/pages/navigationpage.dart' as _i4;

abstract class $AppRouter extends _i5.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    LoginPage.name: (routeData) {
      final args =
          routeData.argsAs<LoginPageArgs>(orElse: () => const LoginPageArgs());
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.LoginPage(key: args.key),
      );
    },
    LogoutPage.name: (routeData) {
      final args = routeData.argsAs<LogoutPageArgs>(
          orElse: () => const LogoutPageArgs());
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.LogoutPage(key: args.key),
      );
    },
    MytaskPage.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.MytaskPage(),
      );
    },
    NavBarPage.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.NavBarPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.LoginPage]
class LoginPage extends _i5.PageRouteInfo<LoginPageArgs> {
  LoginPage({
    _i6.Key? key,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          LoginPage.name,
          args: LoginPageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LoginPage';

  static const _i5.PageInfo<LoginPageArgs> page =
      _i5.PageInfo<LoginPageArgs>(name);
}

class LoginPageArgs {
  const LoginPageArgs({this.key});

  final _i6.Key? key;

  @override
  String toString() {
    return 'LoginPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.LogoutPage]
class LogoutPage extends _i5.PageRouteInfo<LogoutPageArgs> {
  LogoutPage({
    _i6.Key? key,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          LogoutPage.name,
          args: LogoutPageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LogoutPage';

  static const _i5.PageInfo<LogoutPageArgs> page =
      _i5.PageInfo<LogoutPageArgs>(name);
}

class LogoutPageArgs {
  const LogoutPageArgs({this.key});

  final _i6.Key? key;

  @override
  String toString() {
    return 'LogoutPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i3.MytaskPage]
class MytaskPage extends _i5.PageRouteInfo<void> {
  const MytaskPage({List<_i5.PageRouteInfo>? children})
      : super(
          MytaskPage.name,
          initialChildren: children,
        );

  static const String name = 'MytaskPage';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i4.NavBarPage]
class NavBarPage extends _i5.PageRouteInfo<void> {
  const NavBarPage({List<_i5.PageRouteInfo>? children})
      : super(
          NavBarPage.name,
          initialChildren: children,
        );

  static const String name = 'NavBarPage';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}
