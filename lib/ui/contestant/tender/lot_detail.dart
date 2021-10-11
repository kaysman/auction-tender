import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:maliye_app/components/glow_behavior.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/components/labels.dart';
import 'package:maliye_app/components/card_widget.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/exceptions/generic_error_indicator.dart';
import 'package:maliye_app/models/document.dart';
import 'package:maliye_app/models/lot_image.dart';
import 'package:maliye_app/models/tendor_lot.dart';
import 'package:maliye_app/providers/auth_api.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:maliye_app/ui/contestant/tender/application.dart';
import 'package:maliye_app/ui/contestant/tender/doc_upload.dart';
import 'package:maliye_app/ui/contestant/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as path;
import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

class TendorInfo extends StatelessWidget {
  final int lot_id;
  const TendorInfo({Key key, @required this.lot_id}) : super(key: key);

  Future<TendorLot> getTendorDetail() async {
    Dio dio = Dio();
    try {
      var response = await dio.get(Apis.tendorDetail(lot_id));

      print("tender lot detail: ");
      log(response.data.toString());
      return TendorLot.fromJson(response.data);
    } on DioError catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Bäsleşik barada maglumat",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<TendorLot>(
        future: getTendorDetail(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const GenericErrorIndicator();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return TendorInfoBody(lot: snapshot.data);
        },
      ),
    );
  }
}

class TendorInfoBody extends StatefulWidget {
  final TendorLot lot;

  const TendorInfoBody({Key key, @required this.lot}) : super(key: key);

  @override
  _TendorInfoBodyState createState() => _TendorInfoBodyState();
}

class _TendorInfoBodyState extends State<TendorInfoBody> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  bool isLoading = false;
  bool isDownloading = false;
  String _progress = "";
  int seller_id;

  Future<void> getDocuments() async {
    final tender = Provider.of<TenderListProvider>(context, listen: false);
    await tender.getRequiredDocuments();
  }

  Future<Response> checkLotSubmission() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);

    Map<String, dynamic> data = {
      "user_id": apiAuth.authorizedUser.id,
      "lot_id": widget.lot.id,
    };

    setState(() => isLoading = true);

    try {
      Dio dio = Dio();
      var response = await dio.post(
        Apis.tendorCheckSubmission,
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      setState(() => isLoading = false);

      log("tender lot check applied response: " + response.data.toString());

      if (response.statusCode == 200) {
        setState(() => seller_id = response.data['id']);
        return response;
      }
    } on DioError catch (e) {
      setState(() => isLoading = false);
      log(e.response.toString() + " " + e.response.statusCode.toString());

      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      }
    }
  }

  @override
  void initState() {
    getDocuments();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);

    super.initState();
  }

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Näbelli ýalňyşlyk ýüze çykdy'),
          content: Text(
            'Bir zat nädogry boldy. Biraz wagtdan gaýtadan synanyşyň.',
          ),
        ),
      );
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    // Android download directory
    if (Platform.isAndroid) {
      Directory directory = await getExternalStorageDirectory();
      List<String> path_split = directory.path.split('/');
      String path = "";
      for (var v in path_split) {
        if (path_split.indexOf(v) == 0) continue;
        if (v == "Android") {
          break;
        }
        path += "/" + v;
      }
      path += '/Download/';
      Directory savePath = Directory(path);
      return savePath;
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future _getStoragePermission(Permission permission) async {
    if (await permission.request().isGranted) {
      return true;
    } else if (await permission.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await permission.request().isDenied) {
      return false;
    }
  }

  Future<void> _download(String fileLink, String filename) async {
    final dir = await _getDownloadDirectory();

    bool isPermissionStatusGranted =
        await _getStoragePermission(Permission.storage);

    if (isPermissionStatusGranted) {
      final savePath = path.join(dir.path, filename);
      await _startDownload(savePath, fileLink);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  final Dio _dio = Dio();
  Future<void> _startDownload(String savePath, String fileLink) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      setState(() => isDownloading = true);

      final response = await _dio.download(
        fileLink,
        savePath,
        onReceiveProgress: _onReceiveProgress,
      );

      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (exception) {
      result['error'] = exception.toString();
      print(exception);
    } finally {
      setState(() => isDownloading = false);
      await _showNotification(result);
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        priority: Priority.high, importance: Importance.max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Ýüklendi' : 'Näsazlyk',
        isSuccess
            ? 'Faýl üstünlikli ýüklendi.'
            : 'Faýly ýüklemekde ýalňyşlyk çykdy.',
        platform,
        payload: json);
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TenderListProvider>(context);
    final apiAuth = Provider.of<ApiAuth>(context);
    Size size = MediaQuery.of(context).size;
    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: Container(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 1,
                margin: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Text.rich(
                    TextSpan(
                      text: "Geçirilýän Senesi\n".toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(Constants.appBlue),
                      ),
                      children: [
                        TextSpan(
                            text: "${widget.lot.formattedStartingDate()}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            )),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              // lot card
              CardWidget(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: Constants.baslesikInfoText,
                          children: [
                            TextSpan(
                              text: "\nBILDIRIŞ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      BlueLabel(
                        label: "Satyn alyjy: ${widget.lot.organization.name}",
                      ),
                      const SizedBox(height: Constants.defaultMargin8),
                      Text.rich(
                        TextSpan(
                          text: "Mazmuny:\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: " ${widget.lot.assetName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(Constants.appBlue)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: Constants.defaultMargin8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Constants.defaultMargin),
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlueLabel(
                            label: "Talap edilýän resminamalar",
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: state.requiredDocs.map((UploadFile doc) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: Constants.defaultMargin),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.circle, size: 6),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        doc.title,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.lot.technicalRequirements.isNotEmpty)
                const SizedBox(height: Constants.defaultMargin),
              if (widget.lot.technicalRequirements.isNotEmpty)
                CardWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bäsleşige gatnaşmak üçin resminamalaryň elektron görnüşi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.lot.technicalRequirements
                                  .map((LotImage doc) {
                                return Container(
                                  width: size.width,
                                  margin: const EdgeInsets.only(
                                    bottom: Constants.defaultMargin,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xff0057B1)
                                          .withOpacity(0.8),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${doc.filename} (nusga)",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      Spacer(),
                                      if (!isDownloading)
                                        GestureDetector(
                                          onTap: () => _download(
                                            doc.getImage,
                                            doc.filename,
                                          ),
                                          child: SvgIcons.download,
                                        ),
                                      if (isDownloading) Text(_progress),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Neşir edilen gazeti",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (widget.lot.link != null)
                      GestureDetector(
                        onTap: () => _launchURL(widget.lot.link),
                        child: Text.rich(
                          TextSpan(
                            text:
                                "Elektron neşir edilen gazetiň salgysy - maglumaty ýükläp almak üçin:  ",
                            children: [
                              TextSpan(
                                text:
                                    widget.lot.linkText ?? "Doly maglumat ucin",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(Constants.appBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      "Habarlaşmak üçin",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text:
                            "Türkmenistanyň Maliýe we ykdysadyýet ministrligi.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(Constants.appBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: "Telefon belgilerimiz:",
                        children: [
                          TextSpan(
                            text: "  39-46-39; 39-46-38, 39-46-32.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(Constants.appBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: "Salgymyz:",
                        children: [
                          TextSpan(
                            text: "  " +
                                "Aşgabat şäheriniň Arçabil şaýolunyň 156-njy jaýy.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(Constants.appBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Constants.defaultMargin8),
                    if (apiAuth.authorizedUser?.isTeamMember != true)
                      Center(
                        child: SizedBox(
                          width: size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: apiAuth.authorizedUser != null
                                ? onSubmitTap
                                : () => navigateTo(
                                      context,
                                      LoginPage(willPop: true),
                                    ),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 150),
                              child: isLoading
                                  ? const ProgressIndicatorSmall(
                                      color: Colors.white)
                                  : Text(
                                      "Ýüz Tutmak",
                                    ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Işledip bolmady $url';

  void onSubmitTap() async {
    hideKeyboard();

    if (isLoading) {
      return;
    }

    Response response = await checkLotSubmission();

    if (response.data['application_submission'] == null &&
        response.data['form_submission'] == null) {
      setState(() => isLoading = true);
      await applyToLot();
    } else if (response.data['application_submission'] != true) {
      navigateTo(
        context,
        TenderApplicationPage(
          seller_id: seller_id,
          lot_id: widget.lot.id,
          hasNext: response.data['form_submission'] != true,
        ),
      );
    } else if (response.data['form_submission'] != true) {
      navigateTo(
        context,
        TendorDocumentsUpload(
          lot_id: widget.lot.id,
          seller_id: seller_id,
        ),
      );
    } else {
      showSnackbar(context, "Something went wrong");
    }
  }

  applyToLot() async {
    final apiAuth = Provider.of<ApiAuth>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    try {
      Dio dio = Dio();
      Response response = await dio.post(
        Apis.tendorApply,
        data: {
          "user_id": apiAuth.authorizedUser.id,
          "lot_id": widget.lot.id,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      log("apply response " + response.data.toString());

      if (response.statusCode == 201) {
        setState(() => seller_id = response.data['id']);
        navigateTo(
          context,
          TenderApplicationPage(
            seller_id: seller_id,
            lot_id: widget.lot.id,
            hasNext: true,
          ),
        );
      }
    } on DioError catch (e) {
      log(e.response.toString());

      if (e.response.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated)
          setState(() {});
        else {
          navigateTo(context, LoginPage(willPop: true));
        }
      } else {
        showSnackbar(context, "Something went wrong, please try again later");
      }
    } finally {
      setState(() => isLoading = false);
    }
  }
}
