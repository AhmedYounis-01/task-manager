import 'package:flutter/material.dart';
import 'package:task_manager_app/constants/strings.dart';
import 'package:task_manager_app/presentation/screen/create_task_screen.dart';
import 'package:task_manager_app/presentation/screen/new_task_screen.dart';
import 'package:task_manager_app/presentation/screen/splash_screen.dart';
import 'package:task_manager_app/presentation/screen/update_task_scren.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case newTasksScreen:
        return MaterialPageRoute(
          builder: (_) => const NewTaskScreen(),
        );
      case createTaskScreen:
        return MaterialPageRoute(
          builder: (_) => const CreateTaskScreen(),
        );
      case updateTaskScreen:
        final task =
            settings.arguments as Map; // تأكد من أن البيانات تأتي كمهمة
        return MaterialPageRoute(
          builder: (_) => UpdateTaskScreen(task: task),
        );
    }
    return null;
  }
}
