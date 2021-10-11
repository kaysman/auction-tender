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
import 'package:maliye_app/providers/auction_list.dart';
import 'package:maliye_app/ui/contestant/tender/doc_upload.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class DeclinedFiles extends StatefulWidget {
  final List<UploadFile> declinedFiles;
  final List<String> notes;
  final int buyer_id;
  final int lot_id;

  const DeclinedFiles({
    Key key,
    @required this.buyer_id,
    @required this.lot_id,
    @required this.declinedFiles,
    @required this.notes,
  }) : super(key: key);

  @override
  DeclinedFilesState createState() => DeclinedFilesState();
}

class DeclinedFilesState extends State<DeclinedFiles> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Dio dio = Dio();

  List<UploadFile> files = [];
  Map<String, UploadFile> selectedDocuments = {};

  String progressMessage = '';
  bool isUploading = false;
  double percentage = 0;

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

      if (paths.where((element) => element.size > doc.size).isEmpty) {
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
    files = widget.declinedFiles.map((e) {
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
    selectedDocuments = {};
    files = widget.declinedFiles.map((e) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !(selectedDocuments.values.map((e) => e.isUploading).contains(true)),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(centerTitle: false, title: Text("Resminamalar")),
        body: OrientationBuilder(
          builder: (context, orientation){
            return orientation == Orientation.landscape
                ? buildItemsForLandscape()
                : buildItemsForPortrait();
          },
        ),
        bottomNavigationBar: SendFileButton(
          isUploading: isUploading,
          function: submitButton,
        ),
      ),
    );
  }

  buildItemsForLandscape(){
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 4 / 1,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0,
      ),
      children: files.map<Widget>((doc) {
        return buildCardItem(doc);
      }).toList(),
    );
  }

  buildItemsForPortrait(){
    return ListView(
      children: files.map<Widget>((doc) {
        return buildCardItem(doc);
      }).toList(),
    );
  }

  buildCardItem(UploadFile doc) {
    var mb = (doc.size / 1000000).toStringAsFixed(2);
    var note = widget.notes[widget.declinedFiles.indexOf(doc)];
    final size = MediaQuery.of(context).size;
    final canvasColor = const Color(0xFFF45F10);
    return Card(
      margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
      child: ListTile(
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.isNotEmpty)
              Card(
                color: canvasColor.withOpacity(0.07),
                child: SizedBox(
                  width: size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: canvasColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "$note",
                            style: TextStyle(
                              color: canvasColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Row(
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
                            ),
                          ),
                    style: OutlinedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
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
      overflow: TextOverflow.clip,
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

      var response = await dio.put(
        Apis.declinedFiles(widget.lot_id, widget.buyer_id),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: formData,
        onSendProgress: (uploadedBytes, totalBytes) {
          setState(
            () => document.percentage = double.tryParse(
              (uploadedBytes / totalBytes * 100).toStringAsFixed(1),
            ),
          );
        },
      );

      if (response.statusCode >= 201 && response.statusCode < 300) {
        log("${response.data}");
        log("success " + response.data.toString());
        setState(() => document.isUploaded = true);
      }
    } on DioError catch (e) {
      document.setDocument = null;
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
    Iterable<String> requiredFiles =
        widget.declinedFiles.where((e) => e.isRequired).map((e) => e.slug);
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
        Apis.auctionFormSubmit(widget.buyer_id),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      setState(() => isUploading = false);

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
                title: "Gaýtadan iberýän resminamalaryñyz ýüklenildi!",
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
