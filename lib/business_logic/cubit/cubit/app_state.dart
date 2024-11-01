part of 'app_cubit.dart';

@immutable
sealed class AppState {}

final class AppInitial extends AppState {}

final class AppCreateDatabaseState extends AppState {}

final class AppInsertDatabaseState extends AppState {}

final class AppGetDatabaseState extends AppState {}

final class AppDeleteDatabaseState extends AppState {}

final class AppUpdateDatabaseState extends AppState {}

final class AppTasksSortedState extends AppState {}
