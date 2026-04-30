import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/reminder_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/grocery_provider.dart';
import 'providers/shopping_provider.dart';
import 'providers/fitness_provider.dart';
import 'providers/flight_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/subscription_provider.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/flight_detail_screen.dart';

// Global navigator key so we can navigate from anywhere (e.g. notification tap)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Init notifications
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Init home screen widgets
  await WidgetService.init();

  // Handle notification taps — navigate to flight details if payload is flight:id
  NotificationService.onNotificationTap = (payload) {
    if (payload != null && payload.startsWith('flight:')) {
      final flightId = payload.substring('flight:'.length);
      _navigateToFlight(flightId);
    }
  };

  runApp(const CuteApp());
}

void _navigateToFlight(String flightId) async {
  // Wait until navigator is ready
  await Future.delayed(const Duration(milliseconds: 500));

  final context = navigatorKey.currentContext;
  if (context == null) return;

  final flightProvider = context.read<FlightProvider>();
  final flight =
      flightProvider.flights.where((f) => f.id == flightId).firstOrNull;

  if (flight != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => FlightDetailScreen(flight: flight),
      ),
    );
  }
}

class CuteApp extends StatelessWidget {
  const CuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => GroceryProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShoppingProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => FitnessProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => FlightProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => LearningProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider()..load(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Glowup ✨',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
            },
          );
        },
      ),
    );
  }
}
