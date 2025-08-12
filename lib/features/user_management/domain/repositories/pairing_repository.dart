abstract class PairingRepository {
  Future<Map<String, String>> createChildAndGenerateCode({
    required String parentUid,
    required String name,
    required int age,
  });

  Future<void> pairChildDevice({
    required String parentUid,
    required String childId,
    required String pairingCode,
    required Map<String, dynamic> deviceInfo,
  });
}