import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:webviewx/webviewx.dart';

class PlayerView extends StatefulWidget {
  final String? mediaUrl;
  
  const PlayerView({
    this.mediaUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerView> createState() => _PlayerViewState();
}
///========================================================================================
class _PlayerViewState extends State<PlayerView> {
  WebViewXController? webviewController;
  bool isInLoadWebView = true;
  String? mediaUrl;

  
  @override
  void initState() {
    super.initState();
    
    mediaUrl = widget.mediaUrl;
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: isInLoadWebView? 0.01 : 1,
          child: WebViewX(
            width: 300,
            height: isVideo()? 300: 100,
            onWebViewCreated: (ctr) async {
              final webViewContent = await ctr.getContent();
              webviewController = ctr;

              if(webViewContent.sourceType != SourceType.html){
                if(isVideo()) {
                  ctr.loadContent('html/vplayer.html', SourceType.html, fromAssets: true);
                }
                else {
                  ctr.loadContent('html/aplayer.html', SourceType.html, fromAssets: true);
                }
              }
            },
            onPageFinished: (t) async {
              final webViewContent = await webviewController?.getContent();

              if(webViewContent?.sourceType == SourceType.html){
                isInLoadWebView = false;
                await setMediaToPlayer();

                updateMain();
              }
            },
          ),
        ),

        if(isInLoadWebView)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  void updateMain(){
    if(mounted){
      setState(() {});
    }
  }

  Future<void> setMediaToPlayer() async {
    final cmd = '''
      var player = document.getElementById("player");
      //console.log(player == null);
      
      if(player != null){
        player.src = "$mediaUrl";
        /*var source = document.createElement('source');
        source.src = "$mediaUrl";
        player.appendChild(source);*/
      }
    ''';

    await webviewController?.evalRawJavascript(cmd);
  }

  bool isVideo(){
    return PathHelper.getDotExtension(mediaUrl?? '').contains('mp4');
  }
}
