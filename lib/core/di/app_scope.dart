import 'package:flutter/widgets.dart';

import 'app_services.dart';

/// Makes [AppServices] available to every widget below it.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      !identical(services, oldWidget.services);
}

extension AppScopeContext on BuildContext {
  /// `context.services.games.findGames(...)`
  AppServices get services => AppScope.of(this);
}
