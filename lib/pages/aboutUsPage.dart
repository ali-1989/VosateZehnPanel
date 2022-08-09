import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn_panel/system/keys.dart';
import 'package:vosate_zehn_panel/system/requester.dart';
import 'package:vosate_zehn_panel/system/session.dart';
import 'package:vosate_zehn_panel/system/stateBase.dart';
import 'package:vosate_zehn_panel/system/extensions.dart';
import 'package:vosate_zehn_panel/tools/app/appSheet.dart';
import 'package:vosate_zehn_panel/views/notFetchData.dart';
import 'package:webviewx/webviewx.dart';

class AboutUsPage extends StatefulWidget {
  static final route = GoRoute(
      path: 'about_us',
      name: (AboutUsPage).toString().toLowerCase(),
      builder: (BuildContext context, GoRouterState state) => const AboutUsPage(),
  );

  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}
///============================================================================================
class _AboutUsPageState extends StateBase<AboutUsPage> {
  WebViewXController? webviewController;
  late Requester requester;
  bool isLoadWebView = false;
  String? htmlData;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

    requester = Requester();
    requestGetAboutUs();
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
          appBar: AppBar(
            title: Text('درباره ی ما'),
          ),
          body: SafeArea(
              child: buildBody()
          ),
        );
      },
    );
  }

  Widget buildBody(){
    print('---- buildBody');
    return Stack(
      children: [
        Opacity(
          opacity: assistCtr.hasState(state$fetchData)? 1 : 0.01,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('متن درباره ی ما').bold(),

                SizedBox(height: 20),

                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, siz){
                      return WebViewX(
                        width: siz.maxWidth,
                        height: 500,
                        onWebViewCreated: (ctr) async {
                          if(webviewController == null) {
                            webviewController = ctr;
                            await ctr.loadContent('html/editor.html', SourceType.html, fromAssets: true);
                            isLoadWebView = true;

                            if(assistCtr.hasState(state$fetchData)){
                              injectDataToEditor(htmlData!);
                              callState();
                            }
                          }
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 8),

                ElevatedButton(
                    onPressed: onSaveCall,
                    child: Text('ذخیره')
                ),

              ],
            ),
          ),
        ),

        Builder(
          builder: (ctx){
            if(!isLoadWebView){
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if(!assistCtr.hasState(state$fetchData)){
              return NotFetchData(tryClick: tryClick,);
            }

            return SizedBox();
          },
        ),
      ],
    );
  }

  @override
  void onResize(oldW, oldH, newW, newH){
    callState();
    webviewController?.reload();
  }

  void injectDataToEditor(String data) async {
    final d1 = "nicEditors.findEditor('editor1').setContent($data);";
    final res = await webviewController?.evalRawJavascript(d1);

    print(res);
  }

  void onSaveCall() async {
    final d1 = "nicEditors.findEditor('editor1').getContent();";
    final res = await webviewController?.evalRawJavascript(d1);

    if(res != null) {
      requestSetAboutUs(res);
    }
    else {
      AppSheet.showSheet$OperationCannotBePerformed(context);
    }
  }

  void tryClick(){
    print('hhhhhhhhh');
    requestGetAboutUs();
  }

  void requestGetAboutUs(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_about_us_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      print('fail');
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      print('okkk');
      htmlData = data[Keys.data];

      if(webviewController != null){
        injectDataToEditor(htmlData!);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.request(context);
  }

  void requestSetAboutUs(String data){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_about_us_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.data] = data;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      hideLoading();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      AppSheet.showSheet$SuccessOperation(context);
    };

    showLoading();
    requester.request(context);
  }
}
