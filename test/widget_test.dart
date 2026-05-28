import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitheer/core/themes.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/providers/mentor_keys_provider.dart';
import 'package:sitheer/providers/prep_provider.dart';
import 'package:sitheer/providers/schedule_providers.dart';
import 'package:sitheer/providers/settings_provider.dart';
import 'package:sitheer/providers/task_providers.dart';
import 'package:sitheer/providers/timer_providers.dart';
import 'package:sitheer/screens/home/main_scaffold.dart';

void main() {
  testWidgets('prep dashboard loads the main workflows', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => MentorKeysProvider()),
          ChangeNotifierProvider(create: (_) => PrepProvider()),
          ChangeNotifierProvider(create: (_) => MainNavProvider()),
          ChangeNotifierProvider(create: (_) => TaskProviders()),
          ChangeNotifierProvider(create: (_) => TimerProviders()),
          ChangeNotifierProvider(create: (_) => ScheduleProviders()),
        ],
        child: MaterialApp(theme: lightTheme, home: const MainScaffold()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('myTayari'), findsOneWidget);
    expect(find.text('Ask, practice, review, repeat.'), findsOneWidget);
    expect(find.text('Roadmap'), findsWidgets);

    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Every chapter has a material stack.'), findsOneWidget);
  });
}
