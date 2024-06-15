// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i4;
import 'package:geotagcameraapp/pages/navigationpage.dart' as _i2;
import 'package:geotagcameraapp/pages/webpage.dart' as _i1;

abstract class $AppRouter extends _i3.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i3.PageFactory> pagesMap = {
    LoginPage.name: (routeData) {
      final args =
          routeData.argsAs<LoginPageArgs>(orElse: () => const LoginPageArgs());
      return _i3.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.LoginPage(key: args.key),
      );
    },
    NavBarPage.name: (routeData) {
      return _i3.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.NavBarPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.LoginPage]
class LoginPage extends _i3.PageRouteInfo<LoginPageArgs> {
  LoginPage({
    _i4.Key? key,
    List<_i3.PageRouteInfo>? children,
  }) : super(
          LoginPage.name,
          args: LoginPageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LoginPage';

  static const _i3.PageInfo<LoginPageArgs> page =
      _i3.PageInfo<LoginPageArgs>(name);
}

class LoginPageArgs {
  const LoginPageArgs({this.key});

  final _i4.Key? key;

  @override
  String toString() {
    return 'LoginPageArgs{key: $key}';
  }
}

/// generated route for
/// [_i2.NavBarPage]
class NavBarPage extends _i3.PageRouteInfo<void> {
  const NavBarPage({List<_i3.PageRouteInfo>? children})
      : super(
          NavBarPage.name,
          initialChildren: children,
        );

  static const String name = 'NavBarPage';

  static const _i3.PageInfo<void> page = _i3.PageInfo<void>(name);
}
