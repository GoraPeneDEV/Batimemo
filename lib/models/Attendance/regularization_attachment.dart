/// Regularization attachment model
class RegularizationAttachment {
  final String name;
  final String path;
  final int size;
  final String type;

  RegularizationAttachment({
    required this.name,
    required this.path,
    required this.size,
    required this.type,
  });

  factory RegularizationAttachment.fromJson(Map<String, dynamic> json) {
    return RegularizationAttachment(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'type': type,
    };
  }

  /// Get file extension from filename
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if file is an image
  bool get isImage {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file is a PDF
  bool get isPdf {
    return extension == 'pdf';
  }

  /// Format file size for display
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
