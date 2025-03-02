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

      final deviceId = await deviceService.getDeviceId();
      final deviceInfo = await deviceService.getDeviceInfo();

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('devices')
          .doc(deviceId)
          .set({
            'deviceInfo': deviceInfo,
            'lastActiveAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

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

        final deviceId = await deviceService.getDeviceId();
        final deviceInfo = await deviceService.getDeviceInfo();

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(deviceId)
            .set({
              'deviceInfo': deviceInfo,
              'lastActiveAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        add(AuthenticatedEvent(user.uid, role));
      } else {
        add(const UnauthenticatedEvent());
      }
    });
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

          emit(
            AuthState(authenticated: true, userId: currentUser.uid, role: role),
          );
        } else {
          emit(const AuthState(errorMessage: 'User data not found'));
        }
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));
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
            await _firestore.collection('users').doc(event.id).get();
        if (userDoc.exists) {
          emit(
            AuthState(errorMessage: 'User with universityId already exists'),
          );
          return;
        }

        await _firestore.collection('users').doc(currentUser.uid).set({
          'name': event.name,
          'email': event.email,
          'universityId': event.id,
          'role': event.role.name,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final deviceId = await deviceService.getDeviceId();
        final deviceInfo = await deviceService.getDeviceInfo();

        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('devices')
            .doc(deviceId)
            .set({
              'deviceInfo': deviceInfo,
              'lastActiveAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

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
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
