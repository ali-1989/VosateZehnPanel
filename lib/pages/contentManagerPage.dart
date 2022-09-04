import 'package:flutter/material.dart';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/models/BucketModel.dart';
import 'package:app/models/enums.dart';
import 'package:app/pages/bucketEditPage.dart';
import 'package:app/pages/subBucketManagerPage.dart';
import 'package:app/services/pagesEventBus.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/publicAccess.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';

class ContentManagerPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'ContentManager',
      name: (ContentManagerPage).toString().toLowerCase(),
      routes: [
        BuketEditPage.route,
        SubBuketManagerPage.route,
      ],
      builder: (BuildContext context, GoRouterState state) => const ContentManagerPage(),
  );

  const ContentManagerPage({Key? key}) : super(key: key);

  @override
  State<ContentManagerPage> createState() => _ContentManagerPageState();
}
///============================================================================================
class _ContentManagerPageState extends StateBase<ContentManagerPage> {
  Requester requester = Requester();
  BucketTypes levelType = BucketTypes.video;
  List<Map> typesDropdownList = [];
  List<BucketModel> bucketList = [];
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int allCount = 0;
  bool isInLoadData = false;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 12;
    searchFilter.addFilter('is_hide', true);
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
                      dropdownItemBottomGap: 0,
                      gap: 10,
                      dropdownItemTopGap: 5,
                      dropdownHeight: 230,
                      resultTS: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      unselectedItemTS: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      onChange: (v){
                        /// this hack need for correct address bar after open dropdown
                        AppRoute.pushNamed(context, ContentManagerPage.route.name!);

                        if(levelType.id() == v['value']){
                          return;
                        }

                        levelType = BucketTypes.fromId(v['value']);
                        AppDB.setReplaceKv(Keys.setting$bucketType, levelType.id());

                        assistCtr.updateMain();

                        reset();
                        requestData();
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
                      if(itm.imageModel != null){
                        return Image.network(itm.imageModel!.url!, width: 85, fit: BoxFit.fill,);
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
                      Text(itm.title).bold(),

                      SizedBox(height: 5),
                      Text(itm.description?? '').alpha(),
                    ],
                  ),
                ),

                Builder(
                    builder: (ctx) {
                      if(itm.isHide){
                        return Row(
                          children: [
                            SizedBox(width: 10,),
                            Icon(AppIcons.eyeOff, size: 18,),
                          ],
                        );
                      }

                      return SizedBox();
                    }),

                SizedBox(width: 12,),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    onPressed: (){
                      gotoMediaManagerPage(itm);
                    },
                    icon: Icon(AppIcons.apps2, color: Colors.lightBlue,)
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

  void gotoMediaManagerPage(BucketModel bucketModel) async {
    final inject = SubBuketManagerPageInjectData();
    inject.bucket = bucketModel;

    AppRoute.pushNamed(context, SubBuketManagerPage.route.name!, extra: inject);
  }

  void gotoAddPage() async {
    final inject = BuketEditPageInjectData();
    inject.bucketType = levelType;

    AppRoute.pushNamed(context, BuketEditPage.route.name!, extra: inject);
    final event = PagesEventBus.getEventBus((ContentManagerPage).toString());
    event.addEvent('update', (param) {
      reset();
      requestData();
    });
  }

  void gotoEditePage(BucketModel bucketModel) async {
    final inject = BuketEditPageInjectData();
    inject.bucketType = levelType;
    inject.bucket = bucketModel;

    AppRoute.pushNamed(context, BuketEditPage.route.name!, extra: inject);
    final event = PagesEventBus.getEventBus((ContentManagerPage).toString());
    event.addEvent('update', (param) {
      reset();
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

  void reset(){
    refreshController.resetNoData();
    bucketList.clear();
  }

  void requestData(){
    final ul = PublicAccess.findUpperLower(bucketList, searchFilter.ascOrder);
    searchFilter.lower = ul.lowerAsTS;
    searchFilter.upper = ul.upperAsTS;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = levelType.id();
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
