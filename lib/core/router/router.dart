import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/page.dart';
import '../../features/exercises/page.dart';
import '../../features/home/page.dart';
import '../../features/new_workout/new_workout.dart';
import '../../features/training/training.dart';
import '../../features/training_patterns/training_patterns.dart';
import '../firebase/signin.dart';

final router = GoRouter(
  initialLocation: '/home',
  refreshListenable: AuthNotifier(),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final loggingIn = state.matchedLocation == '/login';

    if (user == null && !loggingIn) return '/login';
    if (user != null && loggingIn) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, _) => LoginScreen()),
    GoRoute(path: '/home', builder: (_, _) => HomeScreen()),
    GoRoute(path: '/exercises', builder: (_, _) => ExerciseListScreen()),
    GoRoute(path: '/training', builder: (_, _) => TrainingScreen()),
    GoRoute(path: '/new_workout', builder: (_, _) => NewWorkoutScreen()),
    GoRoute(
      path: '/training_patterns',
      builder: (_, _) => WorkoutTemplateListScreen(),
    ),
  ],
);
