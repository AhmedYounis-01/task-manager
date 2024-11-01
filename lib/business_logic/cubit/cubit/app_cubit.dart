import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite_dev.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());





  static AppCubit get(context) => BlocProvider.of(context);

  List<Map> tasks = [];
  late Database database;

  // Create Database
  void createDatabase() async {
    databaseFactory = sqfliteDatabaseFactoryDefault;
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'todo.db');

    database = await openDatabase(
      path,
      version: 4,
      onCreate: (database, version) {
        database
            .execute(
                "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, description TEXT, startDate TEXT, endDate TEXT)")
            .then((value) {
          Logger().i("Table created");
        }).catchError((error) {
          Logger().i("Error creating table: $error");
        });
      },
      onOpen: (database) {
        this.database = database;
        getDataFromDatabase();
        Logger().i("Database opened");
      },
      onUpgrade: (database, oldVersion, newVersion) {
        if (oldVersion < newVersion) {
          // إعادة إنشاء الجدول عند تحديث الإصدار
          database.execute("DROP TABLE IF EXISTS tasks").then((value) {
            Logger().i("Old table dropped");
            createTable(database); // إعادة إنشاء الجدول
          }).catchError((error) {
            Logger().i("Error dropping table: $error");
          });
        }
      },
    );
    emit(AppCreateDatabaseState());
  }


  void createTable(Database database) {
    database
        .execute(
            "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, description TEXT, startDate TEXT, endDate TEXT)")
        .then((value) {
      Logger().i("Table created");
    }).catchError((error) {
      Logger().i("Error creating table: $error");
    });
  }


  void insertDataFromDatabase({
    required int id,
    required String title,
    required String description,
    required String startDate,
    required String endDate,
  }) async {
    await database.transaction((txn) {
      txn.rawInsert(
        'INSERT INTO tasks(id, title, description, startDate, endDate) VALUES(?, ?, ?, ?, ?)',
        [id, title, description, startDate, endDate],
      ).then((value) {
        Logger().i('$value insert successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(); // بعد الإدراج، اجلب البيانات لعرضها في واجهة المستخدم
      }).catchError((error) {
        Logger().i('Error inserting task: $error');
      });
      return Future.value();
    });
  }

  // Fetch Data from Database
  void getDataFromDatabase() {
    database.rawQuery('SELECT * FROM tasks').then((value) {
      tasks = value;
      emit(AppGetDatabaseState());
    }).catchError((error) {
      Logger().i("Error fetching data: $error");
    });
  }

  deleteData({
    required int id,
  }) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase();
      emit(AppDeleteDatabaseState());
      Logger().i("item deleted from database");
    });
  }

  // review and modify to >> update screen
  void updateTask(Map updatedTask) {
    database.rawUpdate(
      'UPDATE tasks SET title = ?, description = ?, startDate = ?, endDate = ? WHERE id = ?',
      [
        updatedTask['title'],
        updatedTask['description'],
        updatedTask['startDate'],
        updatedTask['endDate'],
        updatedTask['id'],
      ],
    ).then((value) {
      emit(AppUpdateDatabaseState());
      getDataFromDatabase(); // Refresh data after update
    });
  }

  void sortTasksByDate() {
    List<Map> sortedTasks =
        List.from(tasks);
    sortedTasks.sort((a, b) {
      DateTime? startDateA = DateTime.tryParse(a['startDate'] ?? '');
      DateTime? startDateB = DateTime.tryParse(b['startDate'] ?? '');
      startDateA ??= DateTime.now();
      startDateB ??= DateTime.now();
      return startDateA.compareTo(startDateB);
    });
    tasks = sortedTasks;
    emit(AppTasksSortedState());
  }
}
