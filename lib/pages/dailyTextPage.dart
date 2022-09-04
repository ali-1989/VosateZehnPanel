
import 'package:app/managers/fontManager.dart';
import 'package:app/pages/setEventView.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

class DailyTextPage extends StatefulWidget {
  static final route = GoRoute(
    path: 'DailyTextPage',
    name: (DailyTextPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => DailyTextPage(),
  );

  const DailyTextPage({Key? key}) : super(key: key);

  @override
  State<DailyTextPage> createState() => DailyTextPageState();
}
///========================================================================================
class DailyTextPageState extends StateBase<DailyTextPage> {
  Requester requester = Requester();
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';
  EventController eventController = EventController();
  GlobalKey<MonthViewState> gKey = GlobalKey();
  late String engFontFamily;

  @override
  void initState(){
    super.initState();

    engFontFamily = FontManager.instance.getEnglishFont()!.family!;
    //requestData();
  }

  @override
  void dispose() {
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (context, controller, sendData) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text('مدیریت جملات روز'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  Widget buildBody(){
    return Scrollbar(
      trackVisibility: true,
      thumbVisibility: true,
      child: MaxWidth(
        maxWidth: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: MonthView(
            key: gKey,
            controller: eventController,
            startDay: WeekDays.saturday,
            minMonth: DateTime.now().subtract(Duration(days: 60)),
            onCellTap: (List<CalendarEventData> events, DateTime date){
              onCellClick(events, date);
            },
            onEventTap: (CalendarEventData event, DateTime date){
            },
            onPageChange: (dt, idx){
            },
            cellAspectRatio: 1.3,
            weekDayBuilder: (idx){
              final d = SolarHijriDate.weekDayNameInPersian[MathHelper.backwardStepInRing(idx, 5, 7, false)];
              return Text(TextHelper.getFirstWord(d));
            },
            headerBuilder: (dt){
              final solar = SolarHijriDate.from(dt);
              var d = '(${dt.year}-${GregorianDate.from(dt).getMonthName()})';
              d += '  (${solar.getYear()}-${solar.getMonthName()})';

              return ColoredBox(
                color: AppThemes.instance.currentTheme.accentColor,
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: (){
                            gKey.currentState?.previousPage();
                          },
                          child: Text('قبلی')
                      ),

                      Text(d),

                      TextButton(
                          onPressed: (){
                            gKey.currentState?.nextPage();
                          },
                          child: Text('بعدی')
                      ),
                    ],
                  ),
                ),
              );
            },
            cellBuilder: (date, events, isToday, isInMonth,){
              final hasEvent = events.indexWhere((element) => element.date == date) > -1;

              return ColoredBox(
                color: isInMonth? (hasEvent? Colors.green.shade200 : Colors.white) : Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(LocaleHelper.numberToEnglish('${date.day}')!,
                              style: TextStyle(fontFamily: engFontFamily, color: Colors.black87),
                            ),
                            Text('${SolarHijriDate.from(date).getDay()}',
                                style: TextStyle(color: Colors.black54)
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              );
            },
          ),
        ),
      ),
    );
  }

  void requestData(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_daily_text_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js['month'] = 1;
    //js[Keys.searchFilter] = searchFilter.toMap();

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final dList = data['text_list'];

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.prepareUrl();
    requester.bodyJson = js;
    requester.request(context);
  }

  void onCellClick(List<CalendarEventData> events, DateTime date) async {
    final evIdx = events.indexWhere((element) => element.date == date);

    final res = await showDialog(
        context: context,
        builder: (ctx){
          return SetEventView(date: date, description: evIdx > -1 ? events[evIdx].description: null);
        }
    );

    if(res is String) {
      if(res.isEmpty){
        if(evIdx > -1) {
          eventController.remove(events[evIdx]);
        }
      }
      else {
        final ev = CalendarEventData(date: date, title: '', description: res);
        eventController.add(ev);
      }
    }
  }
}

