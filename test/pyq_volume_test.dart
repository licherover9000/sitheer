import 'package:flutter_test/flutter_test.dart';
import 'package:sitheer/model/pyq_volume.dart';

void main() {
  test('PyqVolume parses upload script metadata', () {
    final volume = PyqVolume.fromMap({
      'id': 'gate-cs-pyq-volume-1',
      'examId': 'gate-cs',
      'title': 'GATE CSE PYQ Volume 1',
      'description': 'Uploaded PYQ source PDF volume 1.',
      'order': 1,
      'fileName': 'volume-1.pdf',
      'storagePath': 'content/gate-cs/pyq/volume-1.pdf',
      'contentType': 'application/pdf',
      'sizeBytes': 20166045,
      'sha256':
          '533d5f5b7594cdd61446d7deac185175b6bdf1deb4d163397b63fa769546ff9d',
      'uploadedAt': '2026-06-05T10:15:00.000Z',
    });

    expect(volume.id, 'gate-cs-pyq-volume-1');
    expect(volume.label, 'GATE CSE PYQ Volume 1');
    expect(volume.volumeNumber, 1);
    expect(volume.fileName, 'volume-1.pdf');
    expect(volume.storagePath, 'content/gate-cs/pyq/volume-1.pdf');
    expect(volume.sizeBytes, 20166045);
    expect(volume.displaySubtitle, contains('Volume 1'));
    expect(volume.displaySubtitle, contains('19.2 MB'));
    expect(volume.uploadedAt, isNotNull);
  });
}
