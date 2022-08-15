import 'package:flutter/material.dart';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:vosate_zehn_panel/managers/mediaManager.dart';
import 'package:vosate_zehn_panel/models/BucketModel.dart';
import 'package:vosate_zehn_panel/models/enums.dart';
import 'package:vosate_zehn_panel/pages/mediaManagerPage.dart';
import 'package:vosate_zehn_panel/services/pagesEventBus.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/tools/app/appDb.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/publicAccess.dart';
import 'package:vosate_zehn_panel/tools/searchFilterTool.dart';
import 'package:vosate_zehn_panel/views/emptyData.dart';
import 'package:vosate_zehn_panel/views/notFetchData.dart';

class ContentManagerPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'ContentManager',
      name: (ContentManagerPage).toString().toLowerCase(),
      routes: [
        MediaManagerPage.route,
      ],
      builder: (BuildContext context, GoRouterState state) => const ContentManagerPage(),
  );

  const ContentManagerPage({Key? key}) : super(key: key);

  @override
  State<ContentManagerPage> createState() => _ContentManagerPageState();
}
///============================================================================================
class _ContentManagerPageState extends StateBase<ContentManagerPage> {
  late Requester requester = Requester();
  BucketTypes levelType = BucketTypes.video;
  List<Map> typesDropdownList = [];
  List<BucketModel> bucketList = [];
  bool isInLoadData = false;
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int allCount = 0;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 30;
    final type = AppDB.fetchKv(Keys.setting$bucketType);

    if(type != null){
      levelType = BucketTypes.fromId(type);
    }

    for(final i in BucketTypes.values){
      typesDropdownList.add({'label': i.translate(), 'value': i.id()});
    }

    requestData();
  }

  @override
  void dispose() {
    requester.dispose();
    PagesEventBus.removeFor((ContentManagerPage).toString());

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
            title: Text('مدیریت بخش ${levelType.translate()}'),
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


                    CoolDropdown(
                      dropdownList: typesDropdownList,
                      defaultValue: {'label': levelType.translate(), 'value': levelType.id()},
                      isTriangle: false,
                      iconSize: 10,
                      dropdownItemGap: 0,
                      dropdownItemBottomGap: 5,
                      gap: 10,
                      dropdownItemTopGap: 5,
                      resultTS: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      unselectedItemTS: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      onChange: (v){
                        levelType = BucketTypes.fromId(v['value']);
                        assistCtr.updateMain();

                        AppDB.setReplaceKv(Keys.setting$bucketType, levelType.id());
                        /// this hack need for correct address bar after open dropdown
                        AppRoute.pushNamed(context, ContentManagerPage.route.name!);
                      },
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

                    if(bucketList.isEmpty){
                      return SizedBox(
                        height: 200,
                          child: Center(child: EmptyData())
                      );
                    }

                    return SizedBox(
                      height: 250,
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
                            itemCount: bucketList.length,
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
    final itm = bucketList[idx];

    return InkWell(
      onTap: (){},
      child: Card(
        child: Text(itm.title),
      ),
    );
  }

  void onSearchCall(String txt){
    bucketList.clear();
    searchFilter.searchText = txt;

    requestData();
  }

  void onClearSearchCall(){
    bucketList.clear();
    searchFilter.searchText = null;

    requestData();
  }

  void onLoadingMoreCall(){
    requestData();
  }

  void gotoAddPage() async {
    final inject = MediaManagerPageInjectData();
    inject.bucketType = levelType;

    AppRoute.pushNamed(context, MediaManagerPage.route.name!, extra: inject);
    final event = PagesEventBus.getEventBus((ContentManagerPage).toString());
    event.addEvent('update', (param) {
      print('================================= up');
      requestData();
    });
  }

  void tryClick(){
    requestData();
    assistCtr.updateMain();
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    //callState();
  }

  void requestData(){
    final ul = PublicAccess.findUpperLower(bucketList, searchFilter.ascOrder);
    searchFilter.lower = ul.lower;
    searchFilter.upper = ul.upper;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = levelType.bucketName();
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
      final dList = data['bucket_list'];
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
        final b = BucketModel.fromMap(k);
        b.imageModel = MediaManager.getById(b.mediaId);

        bucketList.add(b);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
    requester.request(context);
  }
}
