import 'package:parental_control_app/features/user_management/domain/repositories/pairing_repository.dart';

class PairChildDeviceUseCase {
  final PairingRepository repository;
  PairChildDeviceUseCase(this.repository);

  Future<void> call({
    required String parentUid,
    required String childId,
    required String pairingCode,
    required Map<String, dynamic> deviceInfo,
  }) {
    return repository.pairChildDevice(
      parentUid: parentUid,
      childId: childId,
      pairingCode: pairingCode,
      deviceInfo: deviceInfo,
    );
  }
}