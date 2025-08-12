import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PairingRemoteDataSource {
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

class PairingRemoteDataSourceImpl implements PairingRemoteDataSource {
  final FirebaseFirestore firestore;
  PairingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<Map<String, String>> createChildAndGenerateCode({
    required String parentUid,
    required String name,
    required int age,
  }) async {
    final String childId = firestore.collection('_ids').doc().id;
    final String pairingCode = _generateCode(8);

    await firestore
        .collection('parents')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .set({
      'childId': childId,
      'name': name,
      'age': age,
      'gender': 'unknown',
      'pairingCode': pairingCode,
      'createdAt': FieldValue.serverTimestamp(),
      'paired': false,
    });

    return {'childId': childId, 'pairingCode': pairingCode};
  }

  @override
  Future<void> pairChildDevice({
    required String parentUid,
    required String childId,
    required String pairingCode,
    required Map<String, dynamic> deviceInfo,
  }) async {
    final doc = await firestore
        .collection('parents')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .get();

    if (!doc.exists) {
      throw Exception('Child not found');
    }
    final serverCode = doc.data()?['pairingCode'];
    if (serverCode != pairingCode) {
      throw Exception('Pairing code mismatch');
    }

    await firestore
        .collection('parents')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .update({
      'paired': true,
      'pairedDevice': deviceInfo,
    });
  }

  String _generateCode(int len) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (var i = 0; i < len; i++) {
      buffer.write(chars[(now + i) % chars.length]);
    }
    return buffer.toString();
  }
}