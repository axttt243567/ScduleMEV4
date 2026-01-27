import 'package:flutter/material.dart';

enum FileType { pdf, jpeg, jpg, png, doc, txt, mp3, mp4 }

class NoteFile {
  final String name;
  final FileType type;
  final String size;
  final String date;
  final String? demoUrl; // For demo images/pdfs from network
  final String? assetPath; // For local asset files

  NoteFile({
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    this.demoUrl,
    this.assetPath,
  });

  IconData get icon {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.jpeg:
      case FileType.jpg:
      case FileType.png:
        return Icons.image;
      case FileType.doc:
        return Icons.description;
      case FileType.txt:
        return Icons.article;
      case FileType.mp3:
        return Icons.audiotrack;
      case FileType.mp4:
        return Icons.videocam;
    }
  }

  Color get color {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFEF4444);
      case FileType.jpeg:
      case FileType.jpg:
        return const Color(0xFF3B82F6);
      case FileType.png:
        return const Color(0xFF10B981);
      case FileType.doc:
        return const Color(0xFF2563EB);
      case FileType.txt:
        return const Color(0xFF6B7280);
      case FileType.mp3:
        return const Color(0xFFF59E0B);
      case FileType.mp4:
        return const Color(0xFF8B5CF6);
    }
  }

  String get extension {
    switch (type) {
      case FileType.pdf:
        return 'PDF';
      case FileType.jpeg:
        return 'JPEG';
      case FileType.jpg:
        return 'JPG';
      case FileType.png:
        return 'PNG';
      case FileType.doc:
        return 'DOC';
      case FileType.txt:
        return 'TXT';
      case FileType.mp3:
        return 'MP3';
      case FileType.mp4:
        return 'MP4';
    }
  }

  bool get isImage =>
      type == FileType.jpeg || type == FileType.jpg || type == FileType.png;
  bool get isPdf => type == FileType.pdf;
  bool get isAudio => type == FileType.mp3;
  bool get isVideo => type == FileType.mp4;
  bool get isDocument => type == FileType.doc || type == FileType.txt;

  bool get isLocalAsset => assetPath != null;
  bool get isNetworkFile => demoUrl != null;
}

class NoteFolder {
  String name;
  Color color;
  IconData icon;
  final List<NoteFolder> subFolders;
  final List<NoteFile> files;
  final String? syncStatus;

  NoteFolder({
    required this.name,
    required this.color,
    required this.icon,
    this.subFolders = const [],
    this.files = const [],
    this.syncStatus,
  });

  int get totalFileCount {
    int count = files.length;
    for (var folder in subFolders) {
      count += folder.totalFileCount;
    }
    return count;
  }

  int get folderCount => subFolders.length;
}
