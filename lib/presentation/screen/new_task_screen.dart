import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/business_logic/cubit/cubit/app_cubit.dart';
import 'package:task_manager_app/constants/color_palette.dart';
import 'package:task_manager_app/constants/strings.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewTaskScreenState createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _textSearchController = TextEditingController();
  List<Map>? searchedForTasks;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = AppCubit.get(context).tasks;
        List<Map> displayList = searchedForTasks ?? cubit;

        return Scaffold(
          appBar: buildAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildSearchField(cubit),
                const SizedBox(height: 15),
                Expanded(
                  child: ConditionalBuilder(
                    condition: displayList.isNotEmpty,
                    builder: (context) => ListView.separated(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        return buildTaskItem(displayList[index], context);
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                    fallback: (context) => searchedNotFound(),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_circle_rounded),
            onPressed: () {
              Navigator.pushNamed(context, createTaskScreen);
            },
          ),
        );
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text("Hi Ahmed"),
      actions: [
        PopupMenuButton<dynamic>(
          icon: Padding(
            padding: const EdgeInsetsDirectional.only(end: 20),
            child: SvgPicture.asset(
              'assets/svgs/filter.svg',
              width: 25,
              height: 25,
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "sort_date",
              child: Row(
                children: [
                  SvgPicture.asset("assets/svgs/calender.svg"),
                  const SizedBox(width: 8),
                  const Text("Sort by Date")
                ],
              ),
            ),
            PopupMenuItem(
              value: "complete_tasks",
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/svgs/task_checked.svg",
                    height: 25,
                  ),
                  const SizedBox(width: 8),
                  const Text("Completed tasks")
                ],
              ),
            ),
            PopupMenuItem(
              value: "Pend_tasks",
              child: Row(
                children: [
                  SvgPicture.asset("assets/svgs/task.svg"),
                  const SizedBox(width: 8),
                  const Text("Pending tasks")
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'sort_date') {
              AppCubit.get(context).sortTasksByDate();
            }
          },
        )
      ],
    );
  }

  Widget buildSearchField(List<Map> taskList) {
    return TextField(
      controller: _textSearchController,
      decoration: InputDecoration(
        hintText: "Search for a task...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onChanged: (searchedAbout) {
        setState(() {
          if (searchedAbout.isNotEmpty) {
            addSearchedItems(searchedAbout, taskList);
          } else {
            searchedForTasks = null;
          }
        });
      },
    );
  }

  void addSearchedItems(String searchedTask, List<Map> taskList) {
    setState(() {
      searchedForTasks = taskList
          .where(
            (task) => (task['title'] ?? '').toString().toLowerCase().startsWith(
                  searchedTask.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  Widget searchedNotFound() {
    return Center(
      child: searchedForTasks != null && searchedForTasks!.isEmpty
          ? const Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kBlackColor,
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/images/app_logo.png"),
                    height: 250,
                    width: 250,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Schedule your tasks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kBlackColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '''Manage your task schedule easily and efficiently''',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kGrey1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTaskItem(Map task, context) {
    return Dismissible(
      key: Key(task['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: task['id']);
      },
      background: Container(color: Colors.redAccent),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task['title'] ?? 'No Title',
                      style: const TextStyle(
                        color: kBlackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    PopupMenuButton<dynamic>(
                      icon: SvgPicture.asset(
                        "assets/svgs/vertical_menu.svg",
                        height: 25,
                      ),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<dynamic>(
                          value: 'edit',
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/svgs/edit.svg"),
                              const SizedBox(width: 8),
                              const Text(
                                'Edit',
                                style: TextStyle(color: kGrey0),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svgs/delete.svg",
                                height: 21,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Delete',
                                style: TextStyle(color: kRed),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            updateTaskScreen,
                            arguments: task,
                          );
                        } else if (value == 'delete') {
                          AppCubit.get(context).deleteData(id: task['id']);
                        }
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    task['description'] ?? 'No Description',
                    style: const TextStyle(color: kGrey0),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.blueGrey[50]),
                  width: double.infinity,
                  height: 45,
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 20, top: 5),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/svgs/calender.svg"),
                        const SizedBox(width: 10),
                        Text(
                          "${formatDate(task['startDate'] as String?)} -- ${formatDate(task['endDate'] as String?)}",
                          style: const TextStyle(color: Colors.blue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'N/A';
    }
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM, yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

}
