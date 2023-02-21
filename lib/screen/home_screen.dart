import 'package:file/memory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:scheduler/component/main_calendar.dart';
import 'package:scheduler/component/schedule_bottom_sheet.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:scheduler/component/schedule_card.dart';
import 'package:scheduler/component/today_banner.dart';
import 'package:scheduler/const/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:scheduler/database/drift_database.dart';
import 'package:scheduler/component/today_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isDismissible: true,
              builder: (_) => ScheduleBottomSheet(
                    selectedDate: selectedDate,
                  ),
              isScrollControlled: true);
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MainCalendar(
              onDaySelected: onDaySelected,
              selectedDate: selectedDate,
            ),
            SizedBox(height: 8),
            StreamBuilder<List<Schedule>>(
                stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                builder: (context, snapshot) {
                  return TodayBanner(
                      selectedDate: selectedDate,
                      count: snapshot.data?.length ?? 0);
                }),
            SizedBox(height: 8),
            Expanded(
                child: StreamBuilder<List<Schedule>>(
              stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
              builder: ((context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: ((context, index) {
                    final schedule = snapshot.data![index];
                    return Dismissible(
                      key: ObjectKey(schedule.id),
                      direction: DismissDirection.startToEnd,
                      onDismissed: ((DismissDirection direction) {
                        GetIt.I<LocalDatabase>().removeSchedules(schedule.id);
                      }),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                        child: ScheduleCard(
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            content: schedule.content),
                      ),
                    );
                  }),
                );
              }),
            ))
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}
