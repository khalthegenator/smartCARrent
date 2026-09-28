import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_car_rent/routes/app_router.dart';

void main() {
  test('router exposes splash and home routes', () {
    final routes = AppRouter.routes.whereType<GoRoute>().toList();
    final paths = routes.map((route) => route.path).toSet();

    expect(paths.contains('/splash'), isTrue);
    expect(paths.contains('/home'), isTrue);
  });
}
