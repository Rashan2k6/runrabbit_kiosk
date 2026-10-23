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
  'quizEntryTitle': 'Not sure? Find your skin type',
  'quizEntrySubtitle': 'Take a quick test',
  'quizTitle': 'Find your skin type',
  'quizSubtitle': 'How does your skin feel normally?',
  'quizIntro':
      'Ready for skincare tailored specifically to your needs? Take a quick test to discover your skin type and unlock personalized product recommendations!',
  'quizProgress': 'Question {n}',
  'yes': 'Yes',
  'no': 'No',
  'quiz.q1': 'Gets skin trouble after using rich creams',
  'quiz.q2': 'Visibly large pores',
  'quiz.q3': 'Have lots of blackheads and sebum',
  'quiz.q4': 'Hair gets greasy quickly',
  'quiz.q5': 'Dry U-zone area (cheeks and chin)',
  'quiz.q6': 'Skin feels tight after cleansing',
  'quiz.q7': 'Oily T-zone area (forehead, nose)',
  'quiz.q8': 'Often gets flaky skin',
  'quiz.q9': 'Skin is usually dry and tight',
  'quizConcernTitle': "What's your main skin concern?",
  'quizConcernSubtitle': 'Choose one skin concern that bothers you the most',
  'quiz.concern.sensitive': 'Sensitive',
  'quiz.concern.sensitive.s1': 'Becomes red and irritated easily',
  'quiz.concern.sensitive.s2': 'Often gets skin reaction and skin trouble',
  'quiz.concern.uneven': 'Uneven',
  'quiz.concern.uneven.s1': 'Has dark spots and pigmented skin',
  'quiz.concern.uneven.s2': 'Has dull and uneven tone',
  'quiz.concern.wrinkled': 'Wrinkled',
  'quiz.concern.wrinkled.s1': 'Reduced skin elasticity',
  'quiz.concern.wrinkled.s2': 'Has visible wrinkles and fine lines',
  'quizResultTitle': 'Your skin type is...',
  'quizResultDisclaimer':
      'This is a suggestion based on your answers. You can change it.',
  'continue': 'Continue',
  'chooseDifferentSkin': 'Choose a different skin type',
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
  'quizEntryTitle': 'නිශ්චිත නැද්ද? ඔබේ සමේ වර්ගය සොයාගන්න', // TODO native speaker review
  'quizEntrySubtitle': 'කෙටි පරීක්ෂණයක් කරන්න', // TODO native speaker review
  'quizTitle': 'ඔබේ සමේ වර්ගය සොයාගන්න', // TODO native speaker review
  'quizSubtitle': 'සාමාන්‍යයෙන් ඔබේ සමට කෙසේ දැනේද?', // TODO native speaker review
  'quizIntro':
      'ඔබේ අවශ්‍යතාවලටම ගැළපෙන සම රැකවරණයට සූදානම්ද? ඔබේ සමේ වර්ගය සොයාගෙන ඔබටම වෙන්වූ නිෂ්පාදන නිර්දේශ ලබාගැනීමට කෙටි පරීක්ෂණය කරන්න!', // TODO native speaker review
  'quizProgress': '{n} වන ප්‍රශ්නය', // TODO native speaker review
  'yes': 'ඔව්', // TODO native speaker review
  'no': 'නැත', // TODO native speaker review
  'quiz.q1': 'ඝන ක්‍රීම් භාවිතයෙන් පසු සමේ ගැටලු ඇති වේ', // TODO native speaker review
  'quiz.q2': 'විශාල වූ සිදුරු පැහැදිලිව පෙනේ', // TODO native speaker review
  'quiz.q3': 'කළු ලප සහ අධික තෙල් සහිත බව ඇත', // TODO native speaker review
  'quiz.q4': 'හිසකෙස් ඉක්මනින් තෙල් සහිත වේ', // TODO native speaker review
  'quiz.q5': 'U-කලාපය (කම්මුල් සහ නිකට) වියළිය', // TODO native speaker review
  'quiz.q6': 'මුහුණ සේදීමෙන් පසු සම තද වූ බවක් දැනේ', // TODO native speaker review
  'quiz.q7': 'තෙල් සහිත T-කලාපය (නළල, නාසය)', // TODO native speaker review
  'quiz.q8': 'බොහෝ විට සමේ පොතු ගැලවී යයි', // TODO native speaker review
  'quiz.q9': 'සම සාමාන්‍යයෙන් වියළි හා තදයි', // TODO native speaker review
  'quizConcernTitle': 'ඔබේ ප්‍රධාන සමේ ගැටලුව කුමක්ද?', // TODO native speaker review
  'quizConcernSubtitle': 'ඔබට වඩාත්ම බලපාන එක් සමේ ගැටලුවක් තෝරන්න', // TODO native speaker review
  'quiz.concern.sensitive': 'සංවේදී', // TODO native speaker review
  'quiz.concern.sensitive.s1': 'පහසුවෙන්ම රතු වී කෝපයට පත් වේ', // TODO native speaker review
  'quiz.concern.sensitive.s2': 'නිතරම සමේ ප්‍රතික්‍රියා සහ ගැටලු ඇති වේ', // TODO native speaker review
  'quiz.concern.uneven': 'අසමාන', // TODO native speaker review
  'quiz.concern.uneven.s1': 'අඳුරු ලප සහ වර්ණක සහිත සම', // TODO native speaker review
  'quiz.concern.uneven.s2': 'අඳුරු සහ අසමාන සමේ පැහැය', // TODO native speaker review
  'quiz.concern.wrinkled': 'රැළි වැටුණු', // TODO native speaker review
  'quiz.concern.wrinkled.s1': 'සමේ ඇදෙනසුලු බව අඩුවීම', // TODO native speaker review
  'quiz.concern.wrinkled.s2': 'පැහැදිලි රැළි සහ සිහින් ඉරි ඇත', // TODO native speaker review
  'quizResultTitle': 'ඔබේ සමේ වර්ගය...', // TODO native speaker review
  'quizResultDisclaimer':
      'මෙය ඔබගේ පිළිතුරු මත පදනම් වූ යෝජනාවකි. ඔබට එය වෙනස් කළ හැක.', // TODO native speaker review
  'continue': 'ඉදිරියට යන්න', // TODO native speaker review
  'chooseDifferentSkin': 'වෙනත් සමේ වර්ගයක් තෝරන්න', // TODO native speaker review
};
