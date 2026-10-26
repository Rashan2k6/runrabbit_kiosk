import 'package:flutter_test/flutter_test.dart';
import 'package:runrabbit_kiosk/app/strings.dart';
import 'package:runrabbit_kiosk/domain/options.dart';

void main() {
  group('Strings concernsHelp and counter rendering with maxConcerns', () {
    test('English strings render "up to 5" and "of 5 chosen"', () {
      const s = Strings('en');
      final helpText = s.t('concernsHelp', {'max': '$maxConcerns'});
      final counterText = s.t('counter', {'n': '2', 'max': '$maxConcerns'});

      expect(helpText, 'Choose up to 5.');
      expect(counterText, '2 of 5 chosen');
    });

    test('Sinhala strings render "{max}ක්" and "{max}න්" with maxConcerns', () {
      const s = Strings('si');
      final helpText = s.t('concernsHelp', {'max': '$maxConcerns'});
      final counterText = s.t('counter', {'n': '3', 'max': '$maxConcerns'});

      expect(helpText, 'උපරිම 5ක් තෝරන්න.');
      expect(counterText, '5න් 3ක් තෝරා ඇත');
    });
  });
}
