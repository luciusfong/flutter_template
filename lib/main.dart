import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_login_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_login_app/features/auth/presentation/pages/login_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize dependencies
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture + BLoC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => di.sl<AuthBloc>(),
        child: LoginPage(),
      ),
    );
  }
}