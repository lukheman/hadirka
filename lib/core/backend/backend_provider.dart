import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/attendance/data/repositories/attendance_repository.dart';
import '../../features/attendance/data/services/attendance_api_service.dart';
import '../../features/services/data/repositories/services_repository.dart';
import '../../features/services/data/services/services_api_service.dart';

final servicesApiServiceProvider = Provider<ServicesApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ServicesApiService(apiClient);
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final service = ref.watch(servicesApiServiceProvider);
  return ServicesRepository(service);
});

final attendanceApiServiceProvider = Provider<AttendanceApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AttendanceApiService(apiClient);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final service = ref.watch(attendanceApiServiceProvider);
  return AttendanceRepository(service);
});

final backendDataTriggerProvider = StateProvider<int>((ref) => 0);

final attendanceLogsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  final service = ref.read(attendanceApiServiceProvider);
  return await service.getHistory('');
});

final leaveApplicationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  return await ref.read(servicesRepositoryProvider).getLeave();
});

final geofenceLocationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  return await ref.read(servicesRepositoryProvider).getGeofence();
});

final loanApplicationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  return await ref.read(servicesRepositoryProvider).getLoans();
});

final employeeListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  return await ref.read(servicesRepositoryProvider).getUsers();
});

final payslipListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(backendDataTriggerProvider);
  final user = ref.watch(authProvider).user;
  final username = user == null
      ? ''
      : (user.nik.trim().isNotEmpty
          ? user.nik.trim()
          : (user.username.trim().isNotEmpty ? user.username.trim() : user.id));
  return await ref.read(servicesRepositoryProvider).getPayslips(username);
});
