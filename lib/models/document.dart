import 'package:file_picker/file_picker.dart';

class UploadFile {
  final int id;
  final String slug;
  final String title;
  final String type;
  final String mimetype;
  final int size;
  final bool isMultiple;
  final bool isRequired;
  final int maxCount;

  //
  String fileName;
  List<PlatformFile> paths;
  bool loadingPath = false;
  String directoryPath;
  bool isUploading = false;
  double percentage = 0.0;
  bool isUploaded = false;
  String error = "";

  UploadFile({
    this.id,
    this.slug,
    this.title,
    this.type,
    this.mimetype,
    this.size,
    this.isMultiple,
    this.isRequired,
    this.maxCount,
  });

  factory UploadFile.fromJson(Map<String, dynamic> json) {
    return UploadFile(
      id: json["id"] ?? 0,
      slug: json["name"] ?? "",
      title: json["title"] ?? "",
      type: json["type"] ?? "",
      mimetype: json["mimetype"] ?? "",
      size: json["size"] ?? 0,
      isMultiple: json["multiple"] ?? false,
      isRequired: json["required"] ?? false,
      maxCount: json["maxcount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": slug,
        "title": title,
        "type": type,
        "mimetype": mimetype,
        "size": size,
        "multiple": isMultiple,
        "required": isRequired,
        "maxcount": maxCount,
      };

  set setDocument(String a) {
    fileName = null;
    paths = null;
    loadingPath = false;
    directoryPath = null;
    isUploading = false;
    percentage = 0.0;
    isUploaded = false;
    error = "";
  }
}

class Document {
  final String title;
  final String note;
  final List<File> files;
  final bool status;

  Document({this.note, this.files, this.status, this.title});

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        title: json['title'] ?? '',
        note: json['note'] ?? '',
        status: json['status'],
        files: ((json['files'] ?? []) as List)
            .map((json) => File.fromJson(json))
            .toList(),
      );
}

class File {
  final String path;
  final String filename;
  final String destination;

  File({this.path, this.filename, this.destination});

  factory File.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return File(
      path: json['path'] ?? '',
      filename: json['filename'] ?? '',
      destination: json['destination'] ?? '',
    );
  }
}
