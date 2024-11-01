import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_app/app_router.dart';
import 'package:task_manager_app/business_logic/cubit/cubit/app_cubit.dart';
import 'package:task_manager_app/business_logic/cubit/cubit/cubit_observer.dart';
import 'package:task_manager_app/constants/strings.dart';

void main() {
  Bloc.observer = MyBlocObserver();

  runApp(AppTask(
    appRouter: AppRouter(),
  ));
}

class AppTask extends StatelessWidget {
  final AppRouter appRouter;
  const AppTask({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: splashScreen, // Define initial route here
        onGenerateRoute: appRouter.generateRoute,
        // the new task is here
      ),
    );
  }
}