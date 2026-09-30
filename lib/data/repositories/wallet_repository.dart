import '../models/models.dart';

abstract interface class WalletRepository {
  Future<Wallet> wallet();
}
