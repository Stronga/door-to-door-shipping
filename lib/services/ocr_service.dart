import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'label_parser.dart';

/// Result of trying on-device OCR. [warning] is set when the user should
/// fill or correct the fields by hand.
class OcrOutcome {
  final ParsedLabel label;
  final String? warning;

  const OcrOutcome({required this.label, this.warning});
}

class OcrService {
  const OcrService();

  /// Runs ML Kit text recognition, then [parseLabelText].
  ///
  /// Never throws for a bad read or a missing native implementation — the
  /// confirm screen still opens with empty fields and [warning] set.
  Future<OcrOutcome> readLabel(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      final text = recognized.text;
      final parsed = parseLabelText(text);
      if (text.trim().isEmpty) {
        return const OcrOutcome(
          label: ParsedLabel(),
          warning:
              'No text found on the photo. Enter the receiver, phone, and destination yourself.',
        );
      }
      if (parsed.receiverName == null &&
          parsed.phone == null &&
          parsed.destination == null) {
        return OcrOutcome(
          label: parsed,
          warning:
              'OCR read the label but could not pick out a name, phone, or destination. Check the fields below.',
        );
      }
      return OcrOutcome(label: parsed);
    } catch (_) {
      return const OcrOutcome(
        label: ParsedLabel(),
        warning:
            'On-device OCR did not run (ML Kit needs a phone build). Enter the fields yourself.',
      );
    } finally {
      try {
        await recognizer.close();
      } catch (_) {
        // Already failed or already closed.
      }
    }
  }
}
