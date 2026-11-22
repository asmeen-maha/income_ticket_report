/// Thai vowels written before the consonant they follow in speech.
const _leadingVowels = {'เ', 'แ', 'โ', 'ใ', 'ไ'};

/// Two-letter initials for an avatar: the first consonant of the first two
/// words, e.g. `สมชาย ตัวอย่าง` → `สต`, `เกษร ใจดี` → `กจ`.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  final letters = words.take(2).map((word) {
    for (final rune in word.runes) {
      final char = String.fromCharCode(rune);
      if (!_leadingVowels.contains(char)) return char.toUpperCase();
    }
    return '';
  });
  final result = letters.join();
  return result.isEmpty ? '?' : result;
}
