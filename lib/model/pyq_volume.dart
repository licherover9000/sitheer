class PyqVolume {
  const PyqVolume({
    required this.id,
    required this.examId,
    required this.label,
    required this.year,
    required this.storagePath,
    this.downloadUrl,
    this.pageCount,
    this.uploadedAt,
  });

  final String id;
  final String examId;
  final String label;
  final int year;
  final String storagePath;
  final String? downloadUrl;
  final int? pageCount;
  final DateTime? uploadedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'examId': examId,
    'label': label,
    'year': year,
    'storagePath': storagePath,
    if (downloadUrl != null) 'downloadUrl': downloadUrl,
    if (pageCount != null) 'pageCount': pageCount,
    if (uploadedAt != null) 'uploadedAt': uploadedAt!.toIso8601String(),
  };

  factory PyqVolume.fromMap(Map<String, dynamic> map) {
    return PyqVolume(
      id: map['id'] as String? ?? '',
      examId: map['examId'] as String? ?? '',
      label: map['label'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      storagePath: map['storagePath'] as String? ?? '',
      downloadUrl: map['downloadUrl'] as String?,
      pageCount: map['pageCount'] as int?,
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt'] as String)
          : null,
    );
  }
}
