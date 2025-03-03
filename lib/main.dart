import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/auth/presentation/bloc/auth_bloc.dart';
import 'package:scheduler/auth/service/device_service.dart';
import 'package:scheduler/common/theme/app_theme.dart';
import 'package:scheduler/config/app_router.dart';
import 'package:toastification/toastification.dart';
import 'common/service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Check permissions
  final hasPermission = await notificationService.checkPermissions();
  debugPrint('Has notification permission: $hasPermission');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (_) => AuthBloc(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                  deviceService: DeviceService(),
                )..add(InitializeAuthEvent()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: context.colors.background),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
