/// Plain Dart translations (English `en`, Sinhala `si`). No code generation,
/// no extra packages. Missing Sinhala keys fall back to English.
///
/// NOTE: the Sinhala text is a first draft and must be reviewed by a native
/// speaker (ideally someone from the store) before going on the real screen.
class Strings {
  const Strings(this.lang);
  final String lang;

  String t(String key, [Map<String, String> args = const {}]) {
    var value = (lang == 'si' ? _si[key] : null) ?? _en[key] ?? key;
    args.forEach((k, v) => value = value.replaceAll('{$k}', v));
    return value;
  }

  String skin(String id) => t('skin.$id');
  String concern(String id) => t('concern.$id');
  String step(String name) => t('step.$name');

  String get otherLanguageName => lang == 'en' ? 'සිංහල' : 'English';
}

const _en = <String, String>{
  'tagline': 'Find the skincare that suits you',
  'touchStart': 'Touch to start',
  'skinTitle': 'What is your skin type?',
  'skinHelp': 'Pick the one that feels most like your skin.',
  'concernsTitle': 'What would you like to improve?',
  'concernsHelp': 'Choose up to 3.',
  'counter': '{n} of 3 chosen',
  'stepsTitle': 'Which steps do you need?',
  'stepsHelp': 'Choose one, several, or the whole routine.',
  'wholeRoutine': 'Whole routine',
  'resultsTitle': 'Your suggested routine',
  'resultsHelp': 'Ask our team if you would like to try any of these.',
  'back': 'Back',
  'next': 'Next',
  'startOver': 'Start over',
  'seeResults': 'See results',
  'shelf': 'Find it at',
  'patchTest':
      'Patch test any new product on a small area of skin first. If you have a skin condition or are pregnant, ask a doctor before trying new products.',
  'reasonSkin': 'Suitable for {skin} skin.',
  'reasonHelps': 'Helps with {list}.',
  'noResults':
      'We could not find a match for these choices. Please ask our team, they are happy to help.',
  'noSuitableStep':
      'No suitable {step} available right now, please ask our team.',
  'error': 'Something went wrong. Please ask our team for help.',
  'step.cleanser': 'Cleanser',
  'step.toner': 'Toner',
  'step.serum': 'Serum',
  'step.moisturiser': 'Moisturiser',
  'step.sunscreen': 'Sunscreen',
  'step.mask': 'Mask',
  'skin.oily': 'Oily',
  'skin.dry': 'Dry',
  'skin.combination': 'Combination',
  'skin.sensitive': 'Sensitive',
  'skin.normal': 'Normal',
  'concern.acne': 'Acne and breakouts',
  'concern.pores': 'Blackheads and open pores',
  'concern.pigmentation': 'Dark spots and pigmentation',
  'concern.dullness': 'Dullness and uneven tone',
  'concern.aging': 'Fine lines and wrinkles',
  'concern.darkcircles': 'Dark circles',
  'concern.dryness': 'Dryness and dehydration',
  'concern.redness': 'Redness and irritation',
};

const _si = <String, String>{
  'tagline': 'ඔබේ සමට ගැළපෙන නිෂ්පාදන සොයාගන්න',
  'touchStart': 'ආරම්භ කිරීමට ස්පර්ශ කරන්න',
  'skinTitle': 'ඔබේ සමේ වර්ගය කුමක්ද?',
  'skinHelp': 'ඔබේ සමට වඩාත්ම සමාන එක තෝරන්න.',
  'concernsTitle': 'ඔබට වැඩිදියුණු කර ගැනීමට අවශ්‍ය කුමක්ද?',
  'concernsHelp': 'උපරිම 3ක් තෝරන්න.',
  'counter': '3න් {n}ක් තෝරා ඇත',
  // TODO(native review): new routine-step text currently falls back to English.
  'resultsTitle': 'ඔබට යෝජිත රටාව',
  'resultsHelp': 'මේවා අත්හදා බැලීමට අවශ්‍ය නම් අපගේ කණ්ඩායමෙන් විමසන්න.',
  'back': 'ආපසු',
  'next': 'ඊළඟ',
  'startOver': 'නැවත ආරම්භ කරන්න',
  'seeResults': 'ප්‍රතිඵල බලන්න',
  'shelf': 'ස්ථානය',
  'patchTest':
      'නව නිෂ්පාදනයක් භාවිතයට පෙර සමේ කුඩා කොටසක පරීක්ෂා කරන්න. ඔබට සමේ රෝගයක් ඇත්නම් හෝ ගර්භණී නම් වෛද්‍යවරයකුගෙන් විමසන්න.',
  'reasonSkin': '{skin} සමට ගැළපේ.',
  'reasonHelps': '{list} සඳහා උපකාරී වේ.',
  'noResults':
      'මෙම තේරීම්වලට ගැළපීමක් සොයාගත නොහැකි විය. කරුණාකර අපගේ කණ්ඩායමෙන් විමසන්න.',
  'error': 'යම් දෝෂයක් සිදු විය. කරුණාකර අපගේ කණ්ඩායමෙන් උදව් ඉල්ලන්න.',
  'step.cleanser': 'මුහුණ සේදීම',
  'step.toner': 'ටෝනර්',
  'step.serum': 'සීරම්',
  'step.moisturiser': 'තෙත්කාරකය',
  'step.sunscreen': 'සන්ස්ක්‍රීන්',
  'step.mask': 'මාස්ක්',
  'skin.oily': 'තෙල් සහිත',
  'skin.dry': 'වියළි',
  'skin.combination': 'මිශ්‍ර',
  'skin.sensitive': 'සංවේදී',
  'skin.normal': 'සාමාන්‍ය',
  'concern.acne': 'කුරුලෑ සහ පිළිකා',
  'concern.pores': 'කළු ලප සහ විවෘත සිදුරු',
  'concern.pigmentation': 'පැල්ලම් සහ වර්ණක',
  'concern.dullness': 'අඳුරු බව සහ අසමාන වර්ණය',
  'concern.aging': 'සිහින් ඉරි සහ රැලි',
  'concern.darkcircles': 'ඇස් වටා අඳුරු වළලු',
  'concern.dryness': 'වියළි බව සහ ජලහීනතාව',
  'concern.redness': 'රතු වීම සහ කෝපය',
};
