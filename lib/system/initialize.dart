import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/api/logger/logger.dart';

import 'package:vosate_zehn_panel/constants.dart';
import 'package:vosate_zehn_panel/managers/settingsManager.dart';
import 'package:vosate_zehn_panel/system/lifeCycleApplication.dart';
import 'package:vosate_zehn_panel/tools/app/appCache.dart';
import 'package:vosate_zehn_panel/tools/app/appDirectories.dart';
import 'package:vosate_zehn_panel/tools/app/appImages.dart';
import 'package:vosate_zehn_panel/tools/app/appLocale.dart';
import 'package:vosate_zehn_panel/tools/app/appManager.dart';
import 'package:vosate_zehn_panel/tools/app/appRoute.dart';
import 'package:vosate_zehn_panel/tools/app/appWebsocket.dart';
import 'package:vosate_zehn_panel/tools/app/downloadUpload.dart';
import 'package:vosate_zehn_panel/tools/deviceInfoTools.dart';

class InitialApplication {
	InitialApplication._();

	static bool isCallInit = false;
	static bool isInitialOk = false;
	static bool isLaunchOk = false;

	static Future<bool> importantInit() async {
		if(kIsWeb){
			AppDirectories.prepareStoragePathsWeb(Constants.appName);
		}
		else {
			await AppDirectories.prepareStoragePathsOs(Constants.appName);
		}

		await DeviceInfoTools.prepareDeviceInfo();
		await DeviceInfoTools.prepareDeviceId();

		return true;
	}

	static Future<bool> onceInit(BuildContext context) async {
		if(isCallInit) {
			return true;
		}

		isCallInit = true;
		AppManager.logger = Logger('${AppDirectories.getTempDir$ex()}/events.txt');

		AppRoute.init();
		await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));

		AppCache.screenBack = const AssetImage(AppImages.background);
		await precacheImage(AppCache.screenBack!, context);
		//PlayerTools.init();

		isInitialOk = true;
		return true;
	}

	static void callOnLaunchUp(){
		if(isLaunchOk) {
			return;
		}

		isLaunchOk = true;

		final eventListener = AppEventListener();
		eventListener.addResumeListener(LifeCycleApplication.onResume);
		eventListener.addPauseListener(LifeCycleApplication.onPause);
		eventListener.addDetachListener(LifeCycleApplication.onDetach);
		WidgetsBinding.instance.addObserver(eventListener);

		AppWebsocket.prepareWebSocket(SettingsManager.settingsModel.wsAddress);

		DownloadUpload.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
		DownloadUpload.uploadManager = UploadManager('${Constants.appName}UploadManager');

		DownloadUpload.downloadManager.addListener(DownloadUpload.commonDownloadListener);
		DownloadUpload.uploadManager.addListener(DownloadUpload.commonUploadListener);
	}
}
