import 'package:flutter/material.dart';
import 'package:logging/logging.dart'; // Add to pubspec.yaml

// ANSI color codes for terminal output
class ConsoleColors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
}

class RouteLoggingObserver extends NavigatorObserver {
  final Logger logger = Logger('Navigation');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info(
      '${ConsoleColors.green}PUSH: Navigating to: ${route.settings.name ?? 'unnamed route'}${ConsoleColors.reset}',
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.info(
      '${ConsoleColors.blue}REPLACE: ${oldRoute?.settings.name ?? 'unnamed route'} with ${newRoute?.settings.name ?? 'unnamed route'}${ConsoleColors.reset}',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.info(
      '${ConsoleColors.yellow}POP: Back to: ${previousRoute?.settings.name ?? 'unnamed route'}${ConsoleColors.reset}',
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    logger.info(
      '${ConsoleColors.red}REMOVE: Removed ${route.settings.name ?? 'unnamed route'}${ConsoleColors.reset}',
    );
    super.didRemove(route, previousRoute);
  }
}
