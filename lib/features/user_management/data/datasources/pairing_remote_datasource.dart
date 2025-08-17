import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class PairingRemoteDataSource {
  Future<String> generateParentQRCode({required String parentUid});
  Future<void> linkChildToParent({
    required String parentUid,
    required String childName,
    required int age,
    required String gender,
    required List<String> hobbies,
  });
  Future<bool> isChildAlreadyLinked({required String childUid});
  Future<String?> getChildParentId({required String childUid});
  Future<List<Map<String, dynamic>>> getParentChildren({required String parentUid});
}

class PairingRemoteDataSourceImpl implements PairingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  
  PairingRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<String> generateParentQRCode({required String parentUid}) async {
    // Verify parent exists
    final parentDoc = await firestore.collection('users').doc(parentUid).get();
    if (!parentDoc.exists || parentDoc.data()?['userType'] != 'parent') {
      throw Exception('Parent not found or invalid user type');
    }

    // Return parentUid as QR content
    return parentUid;
  }

     @override
   Future<void> linkChildToParent({
     required String parentUid,
     required String childName,
     required int age,
     required String gender,
     required List<String> hobbies,
   }) async {
     final userCredential = await auth.signInAnonymously();
     final childUid = userCredential.user!.uid;

     await firestore.collection('users').doc(childUid).set({
       'uid': childUid,
       'name': childName,
       'email': '',
       'avatarUrl': '',
       'userType': 'child',
       'parentId': parentUid,
       'age': age,
       'gender': gender,
       'hobbies': hobbies,
       'createdAt': FieldValue.serverTimestamp(),
       'updatedAt': FieldValue.serverTimestamp(),
     });

     await firestore.collection('users').doc(parentUid).update({
       'childrenIds': FieldValue.arrayUnion([childUid]),
       'updatedAt': FieldValue.serverTimestamp(),
     });

     // Mirror a child profile doc under parent's subtree for per-child data like locations/geofences
     await firestore.collection('users').doc(parentUid)
       .collection('children').doc(childUid).set({
         'uid': childUid,
         'name': childName,
         'age': age,
         'gender': gender,
         'avatarUrl': '',
         'createdAt': FieldValue.serverTimestamp(),
       }, SetOptions(merge: true));
   }

  @override
  Future<bool> isChildAlreadyLinked({required String childUid}) async {
    final childDoc = await firestore.collection('users').doc(childUid).get();
    if (!childDoc.exists) return false;
    
    final data = childDoc.data();
    return data?['userType'] == 'child' && data?['parentId'] != null;
  }

  @override
  Future<String?> getChildParentId({required String childUid}) async {
    final childDoc = await firestore.collection('users').doc(childUid).get();
    if (!childDoc.exists) return null;
    
    final data = childDoc.data();
    if (data?['userType'] == 'child') {
      return data?['parentId'];
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getParentChildren({required String parentUid}) async {
    final childrenSnap = await firestore.collection('users').doc(parentUid)
        .collection('children').get();
    if (childrenSnap.docs.isEmpty) return [];
    return childrenSnap.docs.map((d) => d.data()).toList();
  }
}