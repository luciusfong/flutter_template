// features/auth/data/models/user_model.dart
import 'package:flutter_template/features/auth/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  
  UserModel({required this.id, required this.username});
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);

  get accessToken => null;
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      username: username,
      accessToken: accessToken,
    );
  }
}