import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_api_service.dart';
import '../data/model_user.dart';

class AuthState {
  final bool isLoading;
  final UserAccount? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserAccount? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiService(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authApiServiceProvider);
  return AuthRepository(service);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _repository.restoreSession();
      state = AuthState(user: user);
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(identifier, password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    String? nik,
    required String nama,
    required String email,
    required String noHp,
    required String jabatan,
    required String departemen,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newUserData = {
        'identifier': username.trim(),
        'nik': (nik ?? username).trim().toUpperCase(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'nama': nama.trim(),
        'noHp': noHp.trim(),
        'role': 'karyawan',
        'jabatan': jabatan.trim(),
        'departemen': departemen.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _repository.register(newUserData);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkActivation(String identifier) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.checkActivation(identifier);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  void updateUser({
    String? nama,
    String? email,
    String? noHp,
    String? jabatan,
    String? departemen,
    String? fotoProfil,
  }) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        nama: nama,
        email: email,
        noHp: noHp,
        jabatan: jabatan,
        departemen: departemen,
        fotoProfil: fotoProfil,
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}
