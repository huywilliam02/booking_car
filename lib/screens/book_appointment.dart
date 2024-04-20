import 'dart:convert';
import 'package:citgroupvn_carwash/Const/preference.dart';
import 'package:citgroupvn_carwash/api/api.dart';
import 'package:citgroupvn_carwash/models/addvalueforservice.dart';
import 'package:citgroupvn_carwash/models/booking_appoinment_timeslot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:table_calendar/table_calendar.dart';
import 'appointment_review.dart';
import 'constants.dart';

const darkBlue = Color(0xFF265E9E);
const extraDarkBlue = Color(0xFF91B4D8);

class BookAppointment extends StatefulWidget {
  final List<AddValues>? addValues;
  final int? previousSpecialistID;
  final int? previousTotalValue;
  final int? previousTotalTime;
  BookAppointment({
    Key? key,
    this.previousTotalValue,
    this.previousSpecialistID,
    this.previousTotalTime,
    this.addValues,
  }) : super(key: key);
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  var _previousTotalValue;
  var _previousTotalTime;
  var calendarymd;
  var passData;
  int? timeSlotLength = 0;
  var showSnipper = false;
  var visible = 0;
  var previousSpecialistID;
  var previousServiceData;
  var timeSlot;
  var currentDate;
  var displayDate;
  var dataPass;
  var timeSlotColor;
  DateTime? _selectedDay;
  DateTime? _yesterday;
  List<TimeSlot> ts = <TimeSlot>[];
  List<AddValues>? addvalues;

  @override
  void initState() {
    _yesterday = DateTime.now();
    addvalues = widget.addValues;
    previousSpecialistID = widget.previousSpecialistID;
    var addZero2;
    var addMonthZero2;
    if (DateTime.now().day < 10) {
      addZero2 = '0' + DateTime.now().day.toString();
    } else {
      addZero2 = DateTime.now().day.toString();
    }
    if (DateTime.now().month < 10) {
      addMonthZero2 = '0' + DateTime.now().month.toString();
    } else {
      addMonthZero2 = DateTime.now().month.toString();
    }
    currentDate = DateTime.now().year.toString() +
        '-' +
        addMonthZero2.toString() +
        '-' +
        addZero2.toString();

    displayDate = addZero2.toString() +
        '-' +
        addMonthZero2.toString() +
        '-' +
        DateTime.now().year.toString();
    dataPass = {"id": '$previousSpecialistID', "date": '$currentDate'};
    _loadTimeSlotFirst(dataPass);
    super.initState();
  }

  Future<void> _loadTimeSlotFirst(formatted) async {
    setState(() {});
    var res = await CallApi().postData(formatted, 'time_slots');
    var body = json.decode(res.body);
    var theData = body['data'];
    timeSlotLength = theData.length;
    for (int i = 0; i < theData.length; i++) {
      Map<String, dynamic> map = theData[i];
      ts.add(TimeSlot.fromJson(map));
    }
    setState(() {
      showSnipper = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getDataTimeSlot(data) async {
    setState(() {
      showSnipper = true;
    });
    var res = await CallApi().postData(data, 'time_slots');
    var body = json.decode(res.body);
    var theData = body['data'];
    timeSlotLength = theData.length;
    for (int i = 0; i < theData.length; i++) {
      Map<String, dynamic> map = theData[i];
      ts.add(TimeSlot.fromJson(map));
    }
    setState(() {
      showSnipper = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _previousTotalValue = widget.previousTotalValue;
    _previousTotalTime = widget.previousTotalTime;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 24,
            color: darkBlue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: darkBlue,
            fontSize: 18.0,
            fontFamily: 'FivoSansMedium',
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       FontAwesomeIcons.bars,
        //       size: 22,
        //       color: darkBlue,
        //     ),
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => CustomDrawer(),
        //           ));
        //     },
        //   )
        // ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSnipper,
        child: ListView(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 01, 01),
                lastDay: DateTime.utc(2040, 01, 01),
                focusedDay: _selectedDay ?? DateTime.now(),
                currentDay: _selectedDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'FivoSansMedium',
                  ),
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  weekendTextStyle: TextStyle(color: Colors.white),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  disabledTextStyle: TextStyle(color: Colors.grey),
                  todayTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.0,
                    fontFamily: 'FivoSansMedium',
                  ),
                  holidayTextStyle: TextStyle(color: Colors.grey),
                  todayDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  cellMargin: EdgeInsets.all(9.0),
                ),
                sixWeekMonthsEnforced: true,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white),
                  dowTextFormatter: (date, locale) =>
                      DateFormat.E(locale).format(date)[0],
                ),
                enabledDayPredicate: (dt) => dt.isAfter(DateTime(
                    _yesterday!.year, _yesterday!.month, _yesterday!.day)),
                onDaySelected: (selectedDay, _) {
                  setState(() {
                    _selectedDay = selectedDay;
                    var addZero;
                    var addMonthZero;
                    if (selectedDay.day < 10) {
                      addZero = '0' + selectedDay.day.toString();
                    } else {
                      addZero = selectedDay.day.toString();
                    }
                    if (selectedDay.month < 10) {
                      addMonthZero = '0' + selectedDay.month.toString();
                    } else {
                      addMonthZero = selectedDay.month.toString();
                    }
                    calendarymd = selectedDay.year.toString() +
                        '-' +
                        addMonthZero +
                        '-' +
                        addZero;
                    displayDate = addZero +
                        '-' +
                        addMonthZero +
                        '-' +
                        selectedDay.year.toString();
                    passData = {
                      'id': '$previousSpecialistID',
                      'date': '$calendarymd'
                    };
                    _getDataTimeSlot(passData);
                    currentDate = calendarymd;
                    // print(currentDate);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Time',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 18,
                      fontFamily: 'FivoSansMedium',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  timeSlotLength == 0
                      ? Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            'No Data Available',
                            style: TextStyle(
                              color: darkBlue,
                              fontSize: 18,
                              fontFamily: 'FivoSansMedium',
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.90 / 0.35,
                          ),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: timeSlotLength,
                          itemBuilder: (context, index) {
                            TimeSlot timeslot = ts[index];
                            return Container(
                              height: 33.0,
                              width: MediaQuery.of(context).size.width / 3.5,
                              decoration: BoxDecoration(
                                color: timeSlotColor == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  timeSlot = timeslot.startTime;
                                  setState(() {
                                    timeSlotColor = index;
                                  });
                                },
                                child: Text(
                                  timeslot.startTime,
                                  style: TextStyle(
                                    color: timeSlotColor == index
                                        ? Colors.white
                                        : darkBlue,
                                    fontSize: 12,
                                    fontFamily: 'FivoSansMedium',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Services',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 18,
                      fontFamily: 'FivoSansMedium',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListView.separated(
                    scrollDirection: Axis.vertical,
                    physics: ClampingScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.0),
                    shrinkWrap: true,
                    itemCount: addvalues!.length,
                    itemBuilder: (context, index) {
                      AddValues addvalue = addvalues![index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                            )
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  spreadRadius: -1.0,
                                  offset: Offset(-5, 0)),
                            ],
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    addvalue.serviceName!,
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontSize: 18,
                                      fontFamily: 'FivoSansMedium',
                                    ),
                                  ),
                                ),
                                Text(
                                  SharedPreferenceHelper.getString(
                                          Constants.currencySymbol) +
                                      '${addvalue.servicePrice}',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: 'FivoSansMedium',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Duration : ${addvalue.serviceDuration} Min',
                                        style: TextStyle(
                                          color: extraDarkBlue,
                                          fontSize: 14,
                                          fontFamily: 'FivoSansMedium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  Text(
                                    addvalue.serviceDescription!,
                                    style: TextStyle(
                                      color: extraDarkBlue,
                                      fontSize: 14,
                                      fontFamily: 'FivoSansMedium',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFE9F0F7),
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Payable',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 16,
                            fontFamily: 'FivoSansMediumOblique',
                          ),
                        ),
                        Text(
                          'Duration : $_previousTotalTime Min',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontFamily: 'FivoSansOblique',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          SharedPreferenceHelper.getString(
                                  Constants.currencySymbol) +
                              '$_previousTotalValue',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontFamily: 'FivoSansMedium',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  if (timeSlot != null) {
                    // print('$currentDate');
                    // print('ad value is $addvalues');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentReview(
                            previousDate: currentDate,
                            previousTimeSlot: timeSlot,
                            addvalues: addvalues,
                            previousSpecialistId: previousSpecialistID,
                            previousTotalValue: _previousTotalValue,
                            previousTotalTime: _previousTotalTime,
                            previousDisplayDate: displayDate,
                          ),
                        ));
                  } else {
                    showDialog(
                        builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text('Please select any Timeslot'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('ok'),
                                )
                              ],
                            ),
                        context: context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'FivoSansMedium',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
