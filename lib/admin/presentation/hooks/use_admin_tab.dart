import 'package:flutter_hooks/flutter_hooks.dart';

int useAdminTab() {
  return useState<int>(0).value;
}
