import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_manager_app/business_logic/cubit/cubit/app_cubit.dart';
import 'package:task_manager_app/constants/color_palette.dart';

class UpdateTaskScreen extends StatefulWidget {
  final Map task;
  const UpdateTaskScreen({super.key, required this.task});
  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);
    _rangeStart = DateTime.parse(widget.task['startDate']);
    _rangeEnd = DateTime.parse(widget.task['endDate']);
  }

  @override
  void dispose() {
    //
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is AppUpdateDatabaseState) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        // var cubit = context.read<AppCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Update Task",
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
                  children: [
                    // Calendar widget to select the date range
                    buildCalendarWidget(),

                    // Display selected date range
                    buildDateDisplay(),

                    buildTextInput(
                        'Title', _titleController, "Must have a title"),

                    // Description input
                    buildTextInput('Description', _descriptionController,
                        "Must have a description",
                        maxLines: 4),

                    buildButtonUpdate(),
                    //
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget for Calendar
  Widget buildCalendarWidget() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode:
          RangeSelectionMode.toggledOn, // Enable range selection
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          _rangeStart = selectedDay; // Set the start day to the selected day
          _rangeEnd =
              selectedDay; // Set the end day to the same selected day (single-day selection)
        });
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

  // Widget to show the selected date range
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

  // Generic TextInput field
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

  Widget buildButtonUpdate() {
    var cubit = context.read<AppCubit>();
    return ElevatedButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          if (_rangeStart == null || _rangeEnd == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Please select both start and end dates.")),
            );
          } else {
            // Call cubit to update the task
            cubit.updateTask({
              'id': widget.task['id'], // Preserve original task ID
              'title': _titleController.text,
              'description': _descriptionController.text,
              'startDate': _rangeStart!.toIso8601String(),
              'endDate': _rangeEnd!.toIso8601String(),
            });
          }
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal:138)),
      child: const Text(
        'Update',
        style: TextStyle(
          fontSize: 16,
          color: kWhiteColor,
        ),
      ),
    );
  }
}
