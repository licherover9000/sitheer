import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/core/themes.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/data/prep_catalog.dart' show supportedExams;
import 'package:sitheer/data/prep_content_codec.dart' show examIdFromLabel;
import 'package:sitheer/data/prep_content_registry.dart';
import 'package:sitheer/data/question_bank.dart';
import 'package:sitheer/providers/mentor_keys_provider.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/providers/schedule_providers.dart';
import 'package:sitheer/providers/settings_provider.dart';
import 'package:sitheer/providers/task_providers.dart';
import 'package:sitheer/providers/timer_providers.dart';
import 'package:sitheer/repositories/prep_repository.dart';
import 'package:sitheer/services/auth_service.dart';
import 'package:sitheer/services/notification_service.dart';
import 'package:sitheer/screens/home/main_scaffold.dart';
import 'package:sitheer/firebase_options.dart';

void main() async {
  // Required to run async code before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await AuthService.instance.signInAnonymously();
  } on FirebaseAuthException catch (e, st) {
    debugPrint(
      'Firebase Auth unavailable (${e.code}): ${e.message}. '
      'Enable Authentication in Firebase Console and turn on Anonymous sign-in.',
    );
    debugPrint('$st');
  } catch (e, st) {
    debugPrint('Firebase Auth sign-in failed: $e');
    debugPrint('$st');
  }
  await NotificationService.init();

  // Load exam catalogs into Firestore (first run) and memory.
  try {
    final bundles = await PrepRepository.instance.bootstrapContent();
    PrepContentRegistry.instance.setBundles(bundles);
  } catch (e, st) {
    debugPrint('Prep content bootstrap failed: $e');
    debugPrint('$st');
  }

  // Load the PYQ question bank (seed + JSON assets). Runs after the content
  // registry so exam grouping (chapter -> subject -> exam) resolves.
  try {
    await QuestionBank.instance.load();
    // Best-effort: merge any cloud-hosted questions (Admin-SDK imported) on
    // top of the bundled set. Offline/first-run simply keeps the assets.
    for (final exam in supportedExams) {
      final remote = await PrepRepository.instance.fetchExamQuestions(
        examIdFromLabel(exam),
      );
      QuestionBank.instance.mergeRemote(remote);
    }
  } catch (e, st) {
    debugPrint('Question bank load failed: $e');
    debugPrint('$st');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MentorKeysProvider()),
        ChangeNotifierProvider(create: (_) => PrepProvider()),
        ChangeNotifierProvider(create: (_) => MainNavProvider()),
        ChangeNotifierProvider(create: (_) => TaskProviders()),
        ChangeNotifierProvider(create: (_) => TimerProviders()),
        ChangeNotifierProvider(create: (_) => ScheduleProviders()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'myTayari',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}
