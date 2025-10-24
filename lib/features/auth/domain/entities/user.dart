import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String username;

  const User({
    required this.id,
    required this.name,
    required this.username,
  });

  @override
  List<Object> get props => [id, name, username];
}