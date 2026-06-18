class PyqVolume {
  const PyqVolume({
    required this.id,
    required this.examId,
    required this.label,
    required this.year,
    required this.storagePath,
    this.downloadUrl,
    this.description,
    this.volumeNumber,
    this.fileName,
    this.contentType,
    this.sizeBytes,
    this.sha256,
    this.pageCount,
    this.uploadedAt,
  });

  final String id;
  final String examId;
  final String label;
  final int year;
  final String storagePath;
  final String? downloadUrl;
  final String? description;
  final int? volumeNumber;
  final String? fileName;
  final String? contentType;
  final int? sizeBytes;
  final String? sha256;
  final int? pageCount;
  final DateTime? uploadedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'examId': examId,
    'label': label,
    'title': label,
    'year': year,
    'storagePath': storagePath,
    if (downloadUrl != null) 'downloadUrl': downloadUrl,
    if (description != null) 'description': description,
    if (volumeNumber != null) 'order': volumeNumber,
    if (fileName != null) 'fileName': fileName,
    if (contentType != null) 'contentType': contentType,
    if (sizeBytes != null) 'sizeBytes': sizeBytes,
    if (sha256 != null) 'sha256': sha256,
    if (pageCount != null) 'pageCount': pageCount,
    if (uploadedAt != null) 'uploadedAt': uploadedAt!.toIso8601String(),
  };

  factory PyqVolume.fromMap(Map<String, dynamic> map) {
    final label =
        map['label'] as String? ??
        map['title'] as String? ??
        map['fileName'] as String? ??
        'PYQ volume';

    return PyqVolume(
      id: map['id'] as String? ?? '',
      examId: map['examId'] as String? ?? '',
      label: label,
      year: _readInt(map['year']),
      storagePath: map['storagePath'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String?,
      description: map['description'] as String?,
      volumeNumber: _readIntOrNull(map['order'] ?? map['volumeNumber']),
      fileName: map['fileName'] as String?,
      contentType: map['contentType'] as String?,
      sizeBytes: _readIntOrNull(map['sizeBytes']),
      sha256: map['sha256'] as String?,
      pageCount: _readIntOrNull(map['pageCount']),
      uploadedAt: _readDateTime(map['uploadedAt']),
    );
  }

  String get displaySubtitle {
    final parts = <String>[];
    if (volumeNumber != null) parts.add('Volume $volumeNumber');
    if (year > 0) parts.add('$year');
    if (pageCount != null) parts.add('$pageCount pages');
    if (sizeBytes != null) parts.add(_formatBytes(sizeBytes!));
    return parts.join(' - ');
  }
}

int _readInt(Object? value) => _readIntOrNull(value) ?? 0;

int? _readIntOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _readDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  try {
    final date = (value as dynamic).toDate();
    return date is DateTime ? date : null;
  } catch (_) {
    return null;
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}
