/// Heuristic parse of shipping-label OCR text.
///
/// Pulls a receiver name, a phone number, and a destination when it can.
/// Misses are expected — the confirm screen always lets the user edit.
class ParsedLabel {
  final String? receiverName;
  final String? phone;
  final String? destination;

  const ParsedLabel({this.receiverName, this.phone, this.destination});
}

enum _Field { name, phone, destination, skip, none }

const _destHints = <String>[
  'kumasi',
  'accra',
  'ghana',
  'tema',
  'takoradi',
  'cape coast',
  'tamale',
  'sunyani',
  'lagos',
  'abuja',
  'nigeria',
];

final _phoneRe = RegExp(
  r'(?:\+\d[\d\s().\-]{8,18}\d|\(\d{3}\)[\s.\-]?\d{3}[\s.\-]?\d{4}|\d{3}[\s.\-]\d{3}[\s.\-]\d{4}|\d{10,15})',
);

final _prefixRe = RegExp(
  r'^(to|from|name|receiver|recipient|attn|attention|phone|tel|telephone|mobile|cell|destination|city|town|address)\s*[:\-]\s*',
  caseSensitive: false,
);

final _nameRe = RegExp(
  r"^[A-Za-z][A-Za-z'.\-]+(?:\s+[A-Za-z][A-Za-z'.\-]+){1,3}$",
);

_Field _prefixKind(String line) {
  final match = _prefixRe.matchAsPrefix(line.trim());
  if (match == null) return _Field.none;
  switch (match.group(1)!.toLowerCase()) {
    case 'to':
    case 'name':
    case 'receiver':
    case 'recipient':
    case 'attn':
    case 'attention':
      return _Field.name;
    case 'phone':
    case 'tel':
    case 'telephone':
    case 'mobile':
    case 'cell':
      return _Field.phone;
    case 'destination':
    case 'city':
    case 'town':
    case 'address':
      return _Field.destination;
    case 'from':
      return _Field.skip;
    default:
      return _Field.none;
  }
}

String _stripPrefix(String line) {
  final match = _prefixRe.matchAsPrefix(line.trim());
  if (match == null) return line.trim();
  return line.trim().substring(match.end).trim();
}

bool _looksLikeName(String value) => _nameRe.hasMatch(value);

bool _isPhoneOnly(String value) {
  final match = _phoneRe.firstMatch(value);
  if (match == null) return false;
  final rest = value.replaceRange(match.start, match.end, '').trim();
  return rest.replaceAll(RegExp(r'[\s:.\-()]+'), '').isEmpty;
}

/// Best-effort extraction. Any field may be null.
ParsedLabel parseLabelText(String raw) {
  final lines = raw
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  String? phone;
  for (final line in lines) {
    final match = _phoneRe.firstMatch(line);
    if (match != null) {
      phone = match.group(0)!.replaceAll(RegExp(r'\s+'), ' ').trim();
      break;
    }
  }

  String? destination;
  int? destinationIndex;
  for (var i = 0; i < lines.length; i++) {
    final prefix = _prefixKind(lines[i]);
    if (prefix == _Field.skip || prefix == _Field.phone) continue;
    final stripped = _stripPrefix(lines[i]);
    if (stripped.isEmpty || _isPhoneOnly(stripped)) continue;
    final hinted = _destHints.any(stripped.toLowerCase().contains);
    final explicitDestination = prefix == _Field.destination;
    final hintedButNotAPerson =
        hinted && !(prefix == _Field.name && _looksLikeName(stripped));
    if (explicitDestination || hintedButNotAPerson) {
      destination = stripped;
      destinationIndex = i;
      break;
    }
  }

  String? name;
  final phoneDigits = phone?.replaceAll(RegExp(r'\D'), '');
  for (var i = 0; i < lines.length; i++) {
    if (i == destinationIndex) continue;
    final prefix = _prefixKind(lines[i]);
    if (prefix == _Field.skip ||
        prefix == _Field.phone ||
        prefix == _Field.destination) {
      continue;
    }
    final stripped = _stripPrefix(lines[i]);
    if (!_looksLikeName(stripped)) continue;
    final digits = stripped.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits != null &&
        phoneDigits.isNotEmpty &&
        digits.contains(phoneDigits)) {
      continue;
    }
    name = stripped;
    break;
  }

  return ParsedLabel(
    receiverName: name,
    phone: phone,
    destination: destination,
  );
}
