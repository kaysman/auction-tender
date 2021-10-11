import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:maliye_app/components/custom_dialog.dart';
import 'package:maliye_app/components/doc_send_btn.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/models/document.dart';
import 'package:maliye_app/providers/tendor_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class TendorDocumentsUpload extends StatefulWidget {
  final int lot_id;
  final int seller_id;

  const TendorDocumentsUpload({Key key, this.lot_id, this.seller_id})
      : super(key: key);

  @override
  TendorDocumentsUploadState createState() => TendorDocumentsUploadState();
}

class TendorDocumentsUploadState extends State<TendorDocumentsUpload> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Dio dio = Dio();

  List<UploadFile> files = [];
  Map<String, UploadFile> selectedDocuments = {};

  bool isUploading = false;
  String progressMessage = '';

  selectFile(UploadFile doc) async {
    List<PlatformFile> paths;
    setState(() => doc.loadingPath = true);
    try {
      setState(() => doc.directoryPath = null);
      paths = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: doc.isMultiple,
        allowedExtensions: doc.mimetype.split(" "),
      ))
          ?.files;

      int selectedDocTotalSize = 0;
      for (var i in paths.map((element) => element.size)) {
        selectedDocTotalSize += i;
      }

      if (selectedDocTotalSize < doc.size) {
        setState(() => doc.paths = paths);
      } else {
        var mb = (doc.size / 1000000).toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Göwrümi $mb mb dan uly bolmaly däl."),
          ),
        );
        return;
      }
    } on PlatformException catch (e) {
      log("Unsupported operation" + e.toString());
    } catch (ex) {
      log(ex);
    }
    if (!mounted) return;
    if (doc.paths != null && doc.paths.isNotEmpty) {
      setState(() {
        doc.loadingPath = false;
        log("Supported Extensions: ${doc.paths?.first?.extension}");
        doc.fileName =
            doc.paths != null ? doc.paths.map((e) => e.name).toString() : '...';
        log("Filepath: ${doc.fileName}");
        selectedDocuments['${doc.slug}'] = doc;
      });
      await uploadFile(doc);
    }
  }

  @override
  void initState() {
    Wakelock.enable();
    final state = Provider.of<TenderListProvider>(context, listen: false);
    files = state.requiredDocs.map((e) {
      e.paths = null;
      e.fileName = null;
      e.loadingPath = false;
      e.directoryPath = null;
      e.isUploading = false;
      e.percentage = 0.0;
      e.isUploaded = false;
      e.error = "";
      return e;
    }).toList();
    super.initState();
  }

  @override
  void dispose() {
    final state = Provider.of<TenderListProvider>(context, listen: false);
    files = state.requiredDocs.map((e) {
      e.paths = null;
      e.fileName = null;
      e.loadingPath = false;
      e.directoryPath = null;
      e.isUploading = false;
      e.percentage = 0.0;
      e.isUploaded = false;
      e.error = "";
      return e;
    }).toList();
    super.initState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !selectedDocuments.values.map((e) => e.isUploading).contains(true),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(centerTitle: false, title: Text("Resminamalar")),
        body: Container(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 14),
                children: files.map<Widget>((doc) {
                      var mb = (doc.size / 1000000).toStringAsFixed(2);

                      return Card(
                        margin:
                            const EdgeInsets.only(left: 12, right: 12, top: 8),
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                          text: "${doc.title}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "\n$mb" + "Mb",
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  if (doc.isRequired)
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.info,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      tooltip: "Zerur resminama",
                                    ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(child: _buildDisplayFilePath(doc)),
                                  const SizedBox(width: 6),
                                  if (doc.isUploading)
                                    Text(
                                      "${doc.percentage}%",
                                      style: TextStyle(
                                        color: Color(Constants.appBlue),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (doc.isUploaded && doc.error.isEmpty)
                                    Icon(
                                      Icons.done,
                                      color: const Color(Constants.appBlue),
                                      size: 28,
                                    ),
                                  if (!doc.isUploading && !doc.isUploaded)
                                    OutlinedButton.icon(
                                      onPressed: () => selectFile(doc),
                                      icon: SvgIcons.upload,
                                      label: doc.loadingPath
                                          ? const ProgressIndicatorSmall()
                                          : Text(
                                              "Saýla",
                                              style: TextStyle(
                                                color: Color(Constants.appBlue),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                      style: OutlinedButton.styleFrom(
                                        primary: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList() +
                    [
                      SendFileButton(
                        isUploading: isUploading,
                        function: submitButton,
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildDisplayFilePath(UploadFile doc) {
    final bool isMultiPath = doc.paths != null && doc.paths.isNotEmpty;
    final List<String> names = (isMultiPath
        ? doc.paths.map((e) => e.name).toList()
        : [doc.fileName ?? '']);

    return Text.rich(
      TextSpan(
        text: " ${doc.mimetype.toUpperCase()}   ",
        style: TextStyle(
          color: Color(0xFF491414),
          fontWeight: FontWeight.bold,
        ),
        children: names.map((name) {
          return TextSpan(
            text: name,
            style: Theme.of(context).textTheme.bodyText2,
          );
        }).toList(),
      ),
    );
  }

  uploadFile(UploadFile document) async {
    FormData formData = FormData();

    setState(() {
      progressMessage = "Ýüklenilýär...";
      document.isUploading = true;
    });

    String mimeType = document.mimetype.split("/").first;
    String fileType = document.mimetype.split("/").last;

    formData.files.addAll(
      document.paths.map(
        (e) => MapEntry(
          "${document.slug}",
          MultipartFile.fromFileSync(
            e.path,
            filename: e.name,
            contentType: MediaType(mimeType, fileType),
          ),
        ),
      ),
    );

    try {
      ///
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      var response = await dio.post(
        Apis.tendorFileUpload(widget.lot_id, widget.seller_id),
        options: Options(
          contentType: "multipart/form-data",
          headers: {
            "Authorization": "Bearer $token",
            "connection": "keep-alive",
          },
        ),
        data: formData,
        onSendProgress: (int uploadedBytes, int totalBytes) {
          setState(
            () => document.percentage = double.tryParse(
              (uploadedBytes / totalBytes * 100).toStringAsFixed(1),
            ),
          );
        },
      );
      setState(() => document.isUploading = false);

      if (response.statusCode == 201) {
        log("${response.data}");
        log("success " + response.data.toString());
        setState(() => document.isUploaded = true);
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
        return;
      } else {
        setState(() {
          document.error = e.toString();
        });
        showSnackbar(context, e.toString());
        return;
      }
    } on SocketException {
      showSnackbar(context, "Internet näsazlygy");
    } finally {
      setState(() => document.isUploading = false);
    }
  }

  submitButton() async {
    final docState = Provider.of<TenderListProvider>(context, listen: false);
    Iterable<String> requiredFiles =
        docState.requiredDocs.where((e) => e.isRequired).map((e) => e.slug);
    Iterable<String> selectedFiles = selectedDocuments.keys;
    bool requiredAllSelected =
        requiredFiles.map((e) => selectedFiles.contains(e)).contains(false);

    if (requiredAllSelected) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Zerur resminamalary saylañ")));
      return;
    }

    for (var i in selectedDocuments.values) {
      if (i.isUploading) {
        print(i.paths.map((e) => e.name));
        print(i.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ýüklenýänçä garaşyň"),
          ),
        );
        return;
      }
      if (i.isRequired && i.error.isNotEmpty) {
        print(i.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${i.error} ýalňyşlyk ýüze çykdy."),
          ),
        );
        return;
      }
    }

    setState(() => isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      Dio dio = Dio();
      Response response = await dio.post(
        Apis.tenderFormSubmit(widget.seller_id),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      setState(() => isUploading = false);
      print("form submission response");
      log(response.data.toString());
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 40.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const CustomDialog(
                title:
                    "Bäsleşige gatnaşmak üçin zerur bolan resminamalaryñyz ýüklenildi!",
              ),
            );
          },
        );
      }
    } on DioError catch (e) {
      print(e);
      setState(() => isUploading = false);
      if (e.response?.statusCode == 401) {
        bool updated = await updateAccessToken(context);
        if (updated) setState(() {});
      } else {
        showSnackbar(context, e.response.toString());
      }
      return;
    }
  }
}

