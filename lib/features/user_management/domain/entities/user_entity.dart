import 'package:equatable/equatable.dart';

abstract class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final String userType;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [uid, name, email, avatarUrl, userType, createdAt, updatedAt];
}

class ParentUser extends UserEntity {
  final List<String> childrenIds;

  ParentUser({
    required super.uid,
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.userType,
    required super.createdAt,
    required super.updatedAt,
    required this.childrenIds,
  });

  @override
  List<Object?> get props => [...super.props, childrenIds];
}

class ChildUser extends UserEntity {
  final String parentId;
  final int age;
  final String gender;
  final List<String> hobbies;

  ChildUser({
    required super.uid,
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.userType,
    required super.createdAt,
    required super.updatedAt,
    required this.parentId,
    required this.age,
    required this.gender,
    required this.hobbies,
  });

  @override
  List<Object?> get props => [...super.props, parentId, age, gender, hobbies];
}
