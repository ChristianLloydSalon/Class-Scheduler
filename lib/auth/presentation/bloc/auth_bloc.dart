import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:scheduler/auth/service/device_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part '../event/auth_event.dart';
part '../state/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final DeviceService deviceService;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required this.deviceService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const AuthState()) {
    on<InitializeAuthEvent>(_onInitialize);
    on<AuthenticatedEvent>(_onAuthenticated);
    on<UnauthenticatedEvent>(_onUnauthenticated);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthSignInEvent>(_onSignIn);
    on<AuthSignUpEvent>(_onSignUp);

    add(const InitializeAuthEvent());
  }

  Future<void> _onInitialize(
    InitializeAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final role =
          userDoc.exists
              ? UserRole.values.firstWhere(
                (e) => e.name == userDoc.data()?['role'],
                orElse: () => UserRole.none,
              )
              : UserRole.none;

      await _updateUserDevices(currentUser.uid);

      emit(AuthState(authenticated: true, userId: currentUser.uid, role: role));
    } else {
      emit(const AuthState());
    }

    await _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final role =
            userDoc.exists
                ? UserRole.values.firstWhere(
                  (e) => e.name == userDoc.data()?['role'],
                  orElse: () => UserRole.none,
                )
                : UserRole.none;

        await _updateUserDevices(user.uid);

        // save user to shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('userId', user.uid);
          prefs.setString('role', role.name);
        });

        add(AuthenticatedEvent(user.uid, role));
      } else {
        add(const UnauthenticatedEvent());
      }
    });
  }

  Future<void> _updateUserDevices(String userId) async {
    final deviceId = await deviceService.getDeviceId();
    final deviceInfo = await deviceService.getDeviceInfo();

    final userDoc = await _firestore.collection('users').doc(userId).get();

    final deviceData = {'deviceId': deviceId, 'deviceInfo': deviceInfo};

    if (userDoc.exists) {
      final userData = userDoc.data() ?? {};
      final List<dynamic> devices = userData['devices'] ?? [];

      // Check if device already exists
      final deviceIndex = devices.indexWhere(
        (device) => device['deviceId'] == deviceId,
      );

      if (deviceIndex >= 0) {
        // Update existing device
        devices[deviceIndex] = deviceData;
      } else {
        // Add new device
        devices.add(deviceData);
      }

      // Update user document with devices array
      await _firestore.collection('users').doc(userId).update({
        'devices': devices,
      });
    } else {
      // Create user document with devices array if it doesn't exist
      await _firestore.collection('users').doc(userId).set({
        'devices': [deviceData],
      }, SetOptions(merge: true));
    }
  }

  void _onAuthenticated(AuthenticatedEvent event, Emitter<AuthState> emit) {
    emit(
      AuthState(authenticated: true, userId: event.userId, role: event.role),
    );
  }

  void _onUnauthenticated(UnauthenticatedEvent event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
    await SharedPreferences.getInstance().then((prefs) {
      prefs.remove('userId');
      prefs.remove('role');
    });
    emit(const AuthState());
  }

  Future<void> _onSignIn(AuthSignInEvent event, Emitter<AuthState> emit) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          final role = UserRole.values.firstWhere(
            (e) => e.name == userDoc.data()?['role'],
            orElse: () => UserRole.none,
          );

          // save user to shared preferences
          await SharedPreferences.getInstance().then((prefs) {
            prefs.setString('userId', currentUser.uid);
            prefs.setString('role', role.name);
          });

          emit(
            AuthState(authenticated: true, userId: currentUser.uid, role: role),
          );
        } else {
          emit(const AuthState(errorMessage: 'User data not found'));
        }
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));

      emit(const AuthState(errorMessage: ''));
    }
  }

  Future<void> _onSignUp(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        final userDoc =
            await _firestore
                .collection('user_records')
                .where('universityId', isEqualTo: event.id)
                .get();
        if (userDoc.docs.isNotEmpty) {
          emit(
            AuthState(errorMessage: 'User with id ${event.id} already exists'),
          );
          return;
        }

        await _firestore.collection('users').doc(currentUser.uid).set({
          'universityId': event.id,
          'email': event.email,
          'name': event.name,
          'role': event.role.name,
        }, SetOptions(merge: true));

        await _updateUserDevices(currentUser.uid);

        // save user to shared preferences
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('userId', currentUser.uid);
          prefs.setString('role', event.role.name);
        });

        emit(
          AuthState(
            authenticated: true,
            userId: currentUser.uid,
            role: event.role,
          ),
        );
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));

      emit(const AuthState(errorMessage: ''));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
