import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/customerManager.dart';
import 'package:app/managers/mediaManager.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/ticketModel.dart';
import 'package:app/pages/ticketDetailView.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';

class TicketManagerPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'TicketManager',
      name: (TicketManagerPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => const TicketManagerPage(),
  );

  const TicketManagerPage({Key? key}) : super(key: key);

  @override
  State<TicketManagerPage> createState() => _TicketManagerPageState();
}
///============================================================================================
class _TicketManagerPageState extends StateBase<TicketManagerPage> {
  late Requester requester = Requester();
  List<TicketModel> ticketList = [];
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int allCount = 0;
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 30;

    requestData();
  }

  @override
  void dispose() {
    requester.dispose();
    //PagesEventBus.removeFor((TicketManagerPage).toString());

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
            title: Text('مدیریت تیکت ها'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  Widget buildBody(){
    return Scrollbar(
      trackVisibility: true,
      thumbVisibility: true,
      child: SingleChildScrollView(
        primary: true,
        child: MaxWidth(
          maxWidth: 500,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  hint: 'جستجو',
                  onClearEvent: onClearSearchCall,
                  searchEvent: onSearchCall,
                ),

                SizedBox(height: 5,),

                LayoutBuilder(
                  builder: (ctx, siz) {
                    if(isInLoadData){
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if(!assistCtr.hasState(state$fetchData)){
                      return SizedBox(
                        height: 200,
                          child: Center(child: NotFetchData(tryClick: tryClick,))
                      );
                    }

                    if(ticketList.isEmpty){
                      return SizedBox(
                        height: 200,
                          child: Center(child: EmptyData())
                      );
                    }

                    return SizedBox(
                      height: 340,
                      child: RefreshConfiguration(
                        headerBuilder: () => MaterialClassicHeader(),
                        footerBuilder:  () => PublicAccess.classicFooter,
                        enableScrollWhenRefreshCompleted: true,
                        enableLoadingWhenFailed : true,
                        hideFooterWhenNotFull: true,
                        enableBallisticLoad: true,
                        enableLoadingWhenNoData: false,
                        child: SmartRefresher(
                          enablePullDown: false,
                          enablePullUp: true,
                          controller: refreshController,
                          onRefresh: (){},
                          primary: false,
                          onLoading: onLoadingMoreCall,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: ticketList.length,
                            itemBuilder: (ctx, idx){
                              return buildListItem(idx);
                            },
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListItem(int idx){
    final itm = ticketList[idx];

    return SizedBox(
      key: ValueKey(itm.id),
      height: 80,
      child: InkWell(
        onTap: (){
          gotoInfoPage(itm);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: ClipOval(
                    child: Builder(
                        builder: (ctx){
                          if(itm.senderModel?.profileModel?.url == null){
                            return SizedBox.expand(
                                child: ColoredBox(
                                    color: ColorHelper.textToColor(itm.senderModel?.userName?? '0'))
                            );
                          }

                          return Image.network(itm.senderModel?.profileModel?.url?? '');
                        }
                    ),
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itm.senderModel?.nameFamily?? '--').bold(),

                        SizedBox(height: 10),
                        Flexible(child: Text(itm.data!).alpha()),
                      ],
                    )
                ),

                Text(DateTools.dateAndHmRelative$String(itm.sendDate!)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSearchCall(String txt){
    reset();

    if(txt.isNotEmpty) {
      searchFilter.searchText = txt;
    }

    requestData();
  }

  void onClearSearchCall(){
    reset();
    searchFilter.searchText = null;

    requestData();
  }

  void onLoadingMoreCall(){
    requestData();
  }

  void gotoInfoPage(TicketModel ticketModel) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return TicketDetailView(ticketModel: ticketModel);
        }
    );
  }

  void tryClick(){
    requestData();
    assistCtr.updateMain();
  }

  void reset(){
    refreshController.resetNoData();
    ticketList.clear();
  }

  void requestData(){
    final ul = PublicAccess.findUpperLower(ticketList, searchFilter.ascOrder);
    searchFilter.lower = ul.lowerAsTS;
    searchFilter.upper = ul.upperAsTS;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_tickets';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.searchFilter] = searchFilter.toMap();


    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final tList = data['ticket_list'];
      final mList = data['media_list'];
      final cuList = data['customer_list'];
      allCount = data['all_count']?? 0;
      searchFilter.ascOrder = data[Keys.isAsc]?? false;

      if(tList.length < searchFilter.limit){
        refreshController.loadNoData();
      }
      else {
        if(refreshController.isLoading) {
          refreshController.loadComplete();
        }
      }

      MediaManager.addItemsFromMap(mList);
      CustomerManager.addItemsFromMap(cuList);

      for(final k in tList){
        final t = TicketModel.fromMap(k);
        t.senderModel = CustomerManager.getById(t.senderId);
        //t.senderModel?.profileModel = MediaManager.getById(t.senderModel?.profileModel);
        
        ticketList.add(t);
      }

      if(allCount < 1) {
        allCount = ticketList.length;
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.prepareUrl();
    requester.bodyJson = js;
    requester.request(context);
  }
}
