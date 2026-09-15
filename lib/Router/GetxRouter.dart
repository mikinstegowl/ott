import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/Bindings/BaseControllerBindings.dart';
import 'package:ottapp/Bindings/HomeControllerBindings.dart';
import 'package:ottapp/Bindings/LoginControllerBindings.dart';
import 'package:ottapp/Bindings/ReelShortsBindings.dart';
import 'package:ottapp/Bindings/RegisterControllerBindings.dart';
import 'package:ottapp/Bindings/InfoControllerBindings.dart';
import 'package:ottapp/Bindings/ProfileControllerBindings.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Screens/HomeScreen.dart';
import 'package:ottapp/Screens/LoginScreen.dart';
import 'package:ottapp/Screens/RegisterScreen.dart';
import 'package:ottapp/Screens/InfoScreen.dart';
import 'package:ottapp/Screens/PlayerScreen.dart';
import 'package:ottapp/Screens/ProfileScreen.dart';
import 'package:ottapp/Bindings/PlayerControllerBindings.dart';
import 'package:ottapp/Screens/ViewAllScreen.dart';
import 'package:ottapp/Bindings/ViewAllControllerBindings.dart';
import 'package:ottapp/Screens/MainWrapper.dart';
import 'package:ottapp/Bindings/MainWrapperControllerBindings.dart';
import 'package:ottapp/Screens/LiveVideoScreen.dart';
import 'package:ottapp/Bindings/LiveVideoControllerBindings.dart';
import 'package:ottapp/Screens/WatchlistScreen.dart';
import 'package:ottapp/Bindings/WatchlistControllerBindings.dart';
import 'package:ottapp/Screens/SearchScreen.dart';
import 'package:ottapp/Bindings/SearchControllerBindings.dart';

import 'package:ottapp/Screens/ReelShortsScreen.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RoutesName.registerScreen:
      return getPageRoutes(
        routeName: RoutesName.registerScreen,
        page: () => const RegisterScreen(),
        settings: settings,
        bindings: [RegisterControllerBindings()],
      );
    case RoutesName.homeScreen:
      return getPageRoutes(
        routeName: RoutesName.homeScreen,
        page: () => HomeScreen(),
        settings: settings,
        bindings: [
          BaseControllerBindings(),
          HomeControllerBindings(),
          InfoControllerBindings(),
        ],
      );

    case RoutesName.reelShortsScreen:
      return getPageRoutes(
        routeName: RoutesName.reelShortsScreen,
        page: () => const ReelShortsScreen(),
        settings: settings,
        bindings: [
          BaseControllerBindings(),
          ReelShortsBindings(),
        ],
      );

    case RoutesName.logInScreen:
      return getPageRoutes(
        routeName: RoutesName.logInScreen,
        page: () => const LoginScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), LoginControllerBindings()],
      );
    case RoutesName.infoScreen:
      return getPageRoutes(
        routeName: RoutesName.infoScreen,
        page: () => const InfoScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), InfoControllerBindings()],
      );

    case RoutesName.profileScreen:
      return getPageRoutes(
        routeName: RoutesName.profileScreen,
        page: () => const ProfileScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), ProfileControllerBindings()],
      );

    case RoutesName.playerScreen:
      return getPageRoutes(
        routeName: RoutesName.playerScreen,
        page: () => const PlayerScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), PlayerControllerBindings()],
        transition: Transition.zoom,
      );
    case RoutesName.viewAllScreen:
      return getPageRoutes(
        routeName: RoutesName.viewAllScreen,
        page: () => const ViewAllScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), ViewAllControllerBindings()],
      );
    case RoutesName.mainWrapper:
      return getPageRoutes(
        routeName: RoutesName.mainWrapper,
        page: () => const MainWrapper(),
        settings: settings,
        bindings: [
          BaseControllerBindings(),
          HomeControllerBindings(),
          ProfileControllerBindings(),
          MainWrapperControllerBindings(),
          LiveVideoControllerBindings(),
          SearchControllerBindings(),
        ],
      );
    case RoutesName.liveVideoScreen:
      return getPageRoutes(
        routeName: RoutesName.liveVideoScreen,
        page: () => const LiveVideoScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), LiveVideoControllerBindings()],
      );
    case RoutesName.watchlistScreen:
      return getPageRoutes(
        routeName: RoutesName.watchlistScreen,
        page: () => const WatchlistScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), WatchlistControllerBindings()],
      );
    case RoutesName.searchScreen:
      return getPageRoutes(
        routeName: RoutesName.searchScreen,
        page: () => const SearchScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), SearchControllerBindings()],
      );
    default:
      return getPageRoutes(
        routeName: RoutesName.homeScreen,
        page: () => HomeScreen(),
        settings: settings,
        bindings: [BaseControllerBindings(), HomeControllerBindings()],
      );
  }
}

PageRoute getPageRoutes({
  required String routeName,
  required Function page,
  required RouteSettings settings,
  List<Bindings>? bindings,
  Transition? transition,
}) {
  return GetPageRoute(
    page: () => page(),
    routeName: routeName,
    settings: settings,
    bindings: bindings,
    transition: transition,
  );
}
