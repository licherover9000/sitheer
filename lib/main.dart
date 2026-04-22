import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/themes.dart';
import 'package:sitheer/providers/task_providers.dart';
import 'package:sitheer/providers/timer_providers.dart';
import 'package:sitheer/screens/home/main_scaffold.dart';
import 'firebase_options.dart';

void main() async {
  // Required to run async code before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProviders()),
        ChangeNotifierProvider(create: (_) => TimerProviders()),
      ],
      child: MaterialApp(
        title: 'Sitheer',
        theme: lightTheme,
        home: const MainScaffold(),
      ),
    );
  }
}
