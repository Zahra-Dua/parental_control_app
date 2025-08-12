import 'package:parental_control_app/features/user_management/data/datasources/pairing_remote_datasource.dart';
import 'package:parental_control_app/features/user_management/domain/repositories/pairing_repository.dart';

class PairingRepositoryImpl implements PairingRepository {
  final PairingRemoteDataSource remote;
  PairingRepositoryImpl({required this.remote});

  @override
  Future<Map<String, String>> createChildAndGenerateCode({
    required String parentUid,
    required String name,
    required int age,
  }) {
    return remote.createChildAndGenerateCode(
      parentUid: parentUid,
      name: name,
      age: age,
    );
  }

  @override
  Future<void> pairChildDevice({
    required String parentUid,
    required String childId,
    required String pairingCode,
    required Map<String, dynamic> deviceInfo,
  }) {
    return remote.pairChildDevice(
      parentUid: parentUid,
      childId: childId,
      pairingCode: pairingCode,
      deviceInfo: deviceInfo,
    );
  }
}