import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/arb/app_localizations.dart';
import 'core/themes/app_theme.dart';
import 'presentation/routes/app_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rlkbknypbyrrpxdbohcw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsa2JrbnlwYnlycnB4ZGJvaGN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4OTcyMTIsImV4cCI6MjA4ODQ3MzIxMn0.MIV4ABdU1lnNtuIJAF_uZC83OiLD4A7IVRh177ezx4w',
  );
  runApp(
    const ProviderScope(
      child: LinkMeUpApp(),
    ),
  );
}  

class LinkMeUpApp extends ConsumerWidget {
  const LinkMeUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
