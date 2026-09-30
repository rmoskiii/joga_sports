import '../models/models.dart';

abstract interface class AdminRepository {
  Future<AdminDashboard> dashboard();
}
