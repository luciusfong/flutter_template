import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String? name;
  final String? accessToken;

  const User({
    required this.id,
    required this.username,
    this.name,
    this.accessToken,
  });

  @override
  List<Object> get props => [id, username];
}