import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_manager_app/business_logic/cubit/cubit/app_cubit.dart';
import 'package:task_manager_app/constants/color_palette.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  DateTime _focusedDay = DateTime.now();
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is AppInsertDatabaseState) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        //  var cubit = context.read<AppCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Create new task",
              style: TextStyle(
                color: kBlackColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsetsDirectional.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // calender
                    SizedBox(
                      width: double.infinity,
                      child: buildCalendar(),
                    ),
                    buildDateDisplay(),
                    buildTextInput("Title", titleController, "Must have title"),
                    buildTextInput("Description", descriptionController,
                        "Must have description",
                        maxLines: 4),
                    const SizedBox(height: 15),
                    buildButtons()
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode:
          RangeSelectionMode.toggledOn,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          _rangeStart = selectedDay;
          _rangeEnd =
              selectedDay;  });
      },
      onRangeSelected: (start, end, focusedDay) {
        setState(() {
          _rangeStart = start;
          _rangeEnd = end;
          _focusedDay = focusedDay;
          if (_rangeStart != null && _rangeEnd != null) {}
        });
      },
      onFormatChanged: (format) {
        setState(() {
          // Update your state if needed based on format change
        });
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
    );
  }

  Widget buildDateDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        height: 35,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 20, top: 5),
          child: Text(
            _rangeStart != null && _rangeEnd != null
                ? _rangeStart == _rangeEnd
                    ? "Task starting at ${DateFormat('dd MMM, yyyy').format(_rangeStart!)}"
                    : "Task from ${DateFormat('dd MMM, yyyy').format(_rangeStart!)} - ${DateFormat('dd MMM, yyyy').format(_rangeEnd!)}"
                : "Select a date range",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextInput(
      String label, TextEditingController controller, String errorMessage,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(color: kBlackColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Task $label",
            hintStyle: const TextStyle(color: kGrey1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return errorMessage;
            }
            return null;
          },
          maxLines: maxLines,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget buildButtons() {
    var cubit = context.read<AppCubit>();
    return // button
        Row(
      children: [

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kGrey3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: kBlackColor),
            ),
          ),

        const Padding(padding: EdgeInsets.symmetric(horizontal: 17)),
        
        ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (_rangeStart == null || _rangeEnd == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select both start and end dates."),
                    ),
                  );
                } else {
                  final int taskId =
                      DateTime.now().millisecondsSinceEpoch; // Generate unique id
                  cubit.insertDataFromDatabase(
                    id: taskId,
                    title: titleController.text,
                    description: descriptionController.text,
                    startDate: _rangeStart!
                        .toString(), // Use .toIso8601String() for standard date format
                    endDate: _rangeEnd!.toString(),
                  );
                  cubit.getDataFromDatabase(); // Fetch data after saving
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, color: kWhiteColor),
            ),
          ),

      ],
    );
  }
}
