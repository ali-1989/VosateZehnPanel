import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:webviewx/webviewx.dart';

import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/notFetchData.dart';

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
  bool isInLoadWebView = true;
  Requester requester = Requester();
  bool isInLoadData = false;
  String? htmlData;
  String? htmlDataOnResize;
  String state$fetchData = 'state_fetchData';

  @override
  void initState(){
    super.initState();

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
                        height: siz.maxHeight,
                        onWebViewCreated: (ctr) async {
                          if(webviewController == null) {
                            webviewController = ctr;

                            await ctr.loadContent('html/editor.html', SourceType.html, fromAssets: true);
                            isInLoadWebView = false;

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

        WebViewAware(
          child: Builder(
            builder: (ctx){
              if(isInLoadWebView || isInLoadData){
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
        ),
      ],
    );
  }

  @override
  void onResize(oldW, oldH, newW, newH) async {
    htmlDataOnResize ??= await getEditorData();

    callState();

    webviewController?.reload().then((value) {
      Future.delayed(Duration(milliseconds: 800), (){
        injectDataToEditor(htmlDataOnResize ?? ' ');

        Future.delayed(Duration(milliseconds: 2000), (){
          htmlDataOnResize = null;
        });
      });
    });
  }

  void injectDataToEditor(String data) async {
    final cmd = "nicEditors.findEditor('editor1').setContent('$data');";
    await webviewController?.evalRawJavascript(cmd);
  }

  Future<String?> getEditorData() async {
    final cmd = "nicEditors.findEditor('editor1').getContent();";
    return await webviewController?.evalRawJavascript(cmd);
  }

  void onSaveCall() async {
    final res = await getEditorData();

    if(res != null) {
      requestSetAboutUs(res);
    }
    else {
      AppSheet.showSheet$OperationCannotBePerformed(context);
    }
  }

  void tryClick(){
    requestGetAboutUs();
    assistCtr.updateMain();
  }

  void requestGetAboutUs(){
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_about_us_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.prepareUrl();
    requester.bodyJson = js;

    requester.httpRequestEvents.onAnyState = (req) async {
      isInLoadData = false;
    };

    requester.httpRequestEvents.onFailState = (req) async {
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      htmlData = data[Keys.data];

      if(webviewController != null){
        Future.delayed(Duration(milliseconds: 500), (){
          injectDataToEditor(htmlData?? '');
        });
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInLoadData = true;
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
