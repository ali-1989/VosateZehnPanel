import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/speakerModel.dart';
import 'package:app/pages/addSpeakerPage.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';

class SpeakersManagerPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'SpeakersManagerPage',
      name: (SpeakersManagerPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => const SpeakersManagerPage(),
  );

  const SpeakersManagerPage({Key? key}) : super(key: key);

  @override
  State<SpeakersManagerPage> createState() => _SpeakersManagerPageState();
}
///============================================================================================
class _SpeakersManagerPageState extends StateBase<SpeakersManagerPage> {
  late Requester requester = Requester();
  List<SpeakerModel> speakerList = [];
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int allCount = 0;
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 12;
    requestData();
  }

  @override
  void dispose() {
    requester.dispose();
    //PagesEventBus.removeFor((SpeakersManagerPage).toString());

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
            title: Text('مدیریت گویندگان'),
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
      child: SingleChildScrollView(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: gotoAddPage,
                            child: Text('مورد جدید +')
                        ),

                        SizedBox(width: 40,),
                        Text('تعداد کل: $allCount').bold(),
                      ],
                    ),

                  ],
                ),

                SizedBox(height: 20),

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

                    if(speakerList.isEmpty){
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
                          onLoading: onLoadingMoreCall,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: speakerList.length,
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
    final itm = speakerList[idx];

    return SizedBox(
      key: ValueKey(itm.id),
      height: 80,
      child: InkWell(
        onTap: (){
          gotoEditePage(itm);
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Builder(
                    builder: (ctx){
                      if(itm.profileModel != null){
                        return Image.network(itm.profileModel!.url!, width: 85, fit: BoxFit.fill,);
                      }

                      return Image.asset(AppImages.appIcon, width: 85, fit: BoxFit.fill);
                    },
                  ),
                ),

                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itm.name).bold(),

                      SizedBox(height: 5),
                      Text(itm.description?? '').alpha(),
                    ],
                  ),
                ),

                Builder(
                    builder: (ctx) {
                      /*if(itm.isHide){
                        return Row(
                          children: [
                            SizedBox(width: 10,),
                            Icon(AppIcons.eyeOff, size: 18,),
                          ],
                        );
                      }*/

                      return SizedBox();
                    }),

                SizedBox(width: 12,),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    onPressed: (){
                      deleteItem(itm);
                    },
                    icon: Icon(AppIcons.delete, color: Colors.red,)
                )
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

  void gotoAddPage() async {
    final inject = AddSpeakerPageInjectData();

    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddSpeakerPage(injectData: inject);
        }
    );

    if(result != null && result){
      isInLoadData = true;
      reset();
      requestData();
    }
  }

  void gotoEditePage(SpeakerModel speakerModel) async {
    final inject = AddSpeakerPageInjectData();
    inject.speakerModel = speakerModel;

    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx){
          return AddSpeakerPage(injectData: inject);
        }
    );

    if(result != null && result){
      isInLoadData = true;
      reset();
      requestData();
    }
  }

  void tryClick(){
    requestData();
    assistCtr.updateMain();
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void deleteItem(SpeakerModel itm) {
    AppSheet.showSheetYesNo(context, Text('آیا گوینده حذف شود؟'), () {
      requestDeleteSpeaker(itm.id!);
    }, () {});

  }

  void reset(){
    refreshController.resetNoData();
    speakerList.clear();
  }

  void requestDeleteSpeaker(int id){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'delete_speaker';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = id;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      speakerList.removeWhere((element) => element.id == id);
      allCount--;

      assistCtr.updateMain();
    };

    showLoading();
    requester.request(context);
  }

  void requestData(){
    final ul = PublicAccess.findUpperLower(speakerList, searchFilter.ascOrder);
    searchFilter.lower = ul.lowerAsTS;
    searchFilter.upper = ul.upperAsTS;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_speaker_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.searchFilter] = searchFilter.toMap();

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final dList = data['speaker_list'];
      final mList = data['media_list'];
      allCount = data['all_count'];
      searchFilter.ascOrder = data[Keys.isAsc]?? false;

      if(dList.length < searchFilter.limit){
        refreshController.loadNoData();
      }
      else {
        if(refreshController.isLoading) {
          refreshController.loadComplete();
        }
      }

      MediaManager.addItemsFromMap(mList);

      for(final k in dList){
        final b = SpeakerModel.fromMap(k);
        b.profileModel = MediaManager.getById(b.mediaId);

        speakerList.add(b);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context);
  }
}
