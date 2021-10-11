import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:maliye_app/components/custom_dialog.dart';
import 'package:maliye_app/components/doc_send_btn.dart';
import 'package:maliye_app/components/indicators.dart';
import 'package:maliye_app/config/apis.dart';
import 'package:maliye_app/config/constants.dart';
import 'package:maliye_app/config/extensions.dart';
import 'package:maliye_app/config/icons.dart';
import 'package:maliye_app/models/document.dart';
import 'package:maliye_app/providers/auction_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

const TextStyle appTextStyle = TextStyle(
  color: const Color(0xffebedec),
  fontWeight: FontWeight.bold,
);

class DocumentsUpload extends StatefulWidget {
  final int buyer_id;
  final int lot_id;

  const DocumentsUpload({Key key, this.buyer_id, this.lot_id})
      : super(key: key);

  @override
  DocumentsUploadState createState() => DocumentsUploadState();
}

class DocumentsUploadState extends State<DocumentsUpload> {
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
      setState(() {
        doc.loadingPath = false;
      });

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
      log(ex.toString());
    }
    if (!mounted) return;
    if (doc.paths != null && doc.paths.isNotEmpty) {
      setState(() {
        doc.loadingPath = false;
        log("Supported Extensions: ${doc.paths?.first?.extension}");
        doc.fileName =
            doc.paths != null ? doc.paths.map((e) => e.name).join(',') : '';
        log("Filepath: ${doc.fileName}");
        selectedDocuments['${doc.slug}'] = doc;
      });
      await uploadFile(doc);
    }
  }

  @override
  void initState() {
    Wakelock.enable();
    final state = Provider.of<AuctionListProvider>(context, listen: false);
    files = state.requiredFiles.map((e) {
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
    final state = Provider.of<AuctionListProvider>(context, listen: false);
    selectedDocuments = {};
    files = state.requiredFiles.map((e) {
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
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;

        return WillPopScope(
          onWillPop: () async => !(selectedDocuments.values
              .map((e) => e.isUploading)
              .contains(true)),
          child: Scaffold(
            key: _scaffoldKey,
            extendBody: true,
            appBar: AppBar(
              centerTitle: false,
              title: Text("Resminamalar", style: appTextStyle),
              actions: [
                if (orientation == Orientation.landscape)
                  SizedBox(
                    width: size.width * 0.2,
                    child: SendFileButton(
                      isUploading: isUploading,
                      function: () => submitButton(context),
                      inAppBar: true,
                    ),
                  ),
              ],
            ),
            body: orientation == Orientation.landscape
                ? buildItemsForLandscape()
                : buildItemsForPortrait(size.width >= 600),
            bottomNavigationBar: orientation == Orientation.landscape
                ? null
                : SendFileButton(
                    isUploading: isUploading,
                    function: () => submitButton(context),
                  ),
          ),
        );
      },
    );
  }

  buildItemsForLandscape() {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 4 / 1,
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 16.0,
      ),
      children: files.map<Widget>((doc) {
        return buildCardItem(doc);
      }).toList(),
    );
  }

  buildItemsForPortrait([bool bigScreen = false]) {
    if (bigScreen) {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 4 / 1.8,
        mainAxisSpacing: 16.0,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        children: files.map<Widget>((doc) {
          return buildCardItem(doc);
        }).toList(),
      );
    } else {
      return ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: files.map<Widget>((doc) {
          return buildCardItem(doc);
        }).toList(),
      );
    }
  }

  buildCardItem(UploadFile doc) {
    var mb = (doc.size / 1000000).toStringAsFixed(2);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        title: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                    text: "${doc.title}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
            if (doc.isUploaded && doc.error.isEmpty)
              Icon(
                Icons.done,
                color: const Color(Constants.appBlue),
                size: 28,
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

      var response = await dio.post(
        Apis.uploadFile(widget.buyer_id, widget.lot_id),
        options: Options(
          contentType: "multipart/form-data",
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
        data: formData,
        onSendProgress: (int uploadedBytes, int totalBytes) {
          setState(() {
            document.percentage = double.tryParse(
              (uploadedBytes / totalBytes * 100).toStringAsFixed(0),
            );
          });
        },
      );

      setState(() => document.isUploading = false);

      if (response.statusCode == 201) {
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

  submitButton(BuildContext context) async {
    final docState = Provider.of<AuctionListProvider>(context, listen: false);
    Iterable<String> requiredFiles =
        docState.requiredFiles.where((e) => e.isRequired).map((e) => e.slug);
    Iterable<String> selectedFiles = selectedDocuments.keys;
    bool requiredAllSelected =
        requiredFiles.map((e) => selectedFiles.contains(e)).contains(false);

    if (requiredAllSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Zerur resminamalary saýlañ"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (var i in selectedDocuments.values) {
      if (i.isUploading) {
        print(i.paths.map((e) => e.name));
        print(i.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ýüklenýänçä garaşyň"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (i.isRequired && i.error.isNotEmpty) {
        print(i.fileName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${i.error} ýalňyşlyk ýüze çykdy."),
            behavior: SnackBarBehavior.floating,
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
                    "Bäsleşikli söwda gatnaşmak üçin zerur bolan resminamalaryñyz ýüklenildi!",
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
