/// Minimal English/Bangla translation. Strings are keyed by their English
/// text, so any key missing from [_bn] simply falls back to English.
class AppStrings {
  static String languageCode = 'en';

  static bool get isBangla => languageCode == 'bn';

  static const Map<String, String> _bn = {
    // Navigation
    'Home': 'হোম',
    'Tools': 'টুলস',
    'History': 'ইতিহাস',
    'Metrics': 'মেট্রিক্স',
    'Settings': 'সেটিংস',
    'Info': 'তথ্য',
    'Menu': 'মেনু',
    'All Tools': 'সব টুলস',
    'Water Level': 'ওয়াটার লেভেল',

    // Tools
    'Camera Level': 'ক্যামেরা লেভেল',
    'Plumb Level': 'প্লাম্ব লেভেল',
    'Protractor': 'প্রোট্র্যাক্টর',
    'Compass': 'কম্পাস',
    'Ruler': 'রুলার',
    'Slope / Roof Pitch': 'ঢাল / ছাদের পিচ',
    'Height Meter': 'উচ্চতা মাপক',
    'Sound Meter': 'শব্দ মাপক',
    'Metal Detector': 'মেটাল ডিটেক্টর',
    'Surface Level': 'সারফেস লেভেল',

    // Home
    'Lock': 'লক',
    'Sound': 'সাউন্ড',
    'Vibration': 'ভাইব্রেশন',
    'Theme': 'থিম',
    'Save': 'সেভ',
    'Degrees': 'ডিগ্রি',
    '% Grade': '% গ্রেড',
    'LEVEL': 'সমান',
    'Calibrated Successfully': 'ক্যালিব্রেশন সফল হয়েছে',
    'Calibration Reset!': 'ক্যালিব্রেশন রিসেট হয়েছে!',
    'Save reading': 'রিডিং সেভ করুন',
    'Label (e.g. "Shelf in kitchen")': 'নাম (যেমন "রান্নাঘরের তাক")',
    'Cancel': 'বাতিল',
    'Reading': 'রিডিং',
    'Reading Saved': 'রিডিং সেভ হয়েছে',

    // Settings
    'Dark Mode': 'ডার্ক মোড',
    'Dark theme is active': 'ডার্ক থিম চালু আছে',
    'Light theme is active': 'লাইট থিম চালু আছে',
    'Play a sound when the level is centred': 'লেভেল সমান হলে শব্দ হবে',
    'Vibrate when the level is centred': 'লেভেল সমান হলে ভাইব্রেট হবে',
    'Language': 'ভাষা',
    'Rate App': 'রেটিং দিন',
    'Enjoying the app? Leave a review': 'অ্যাপটি ভালো লাগলে রিভিউ দিন',
    'Share App': 'অ্যাপ শেয়ার করুন',
    'Tell your friends about it': 'বন্ধুদের জানান',
    'Privacy Policy': 'প্রাইভেসি পলিসি',
    'How we handle your data': 'আমরা কীভাবে আপনার তথ্য ব্যবহার করি',
    'Version': 'ভার্সন',
    'Our Other Apps': 'আমাদের অন্যান্য অ্যাপ',
    'Could not open link': 'লিংক খোলা যায়নি',

    // History
    'Export CSV': 'CSV এক্সপোর্ট',
    'Clear all readings?': 'সব রিডিং মুছবেন?',
    'This will permanently delete every saved reading.':
        'সব সেভ করা রিডিং স্থায়ীভাবে মুছে যাবে।',
    'Clear': 'মুছুন',
    'No saved readings yet.\nUse the Save button on the home screen.':
        'এখনো কোনো রিডিং সেভ করা হয়নি।\nহোম স্ক্রিনের সেভ বাটন ব্যবহার করুন।',

    // Shared tool UI
    'HOLD': 'হোল্ড',
    'HELD — Tap to resume': 'হোল্ড করা — আবার চালু করতে ট্যাপ করুন',
    'Calibrate': 'ক্যালিব্রেট',
    'Reset': 'রিসেট',
    'Start': 'শুরু',
    'Stop': 'বন্ধ',
    'Sensor not available on this device.': 'এই ডিভাইসে সেন্সর নেই।',

    // Camera
    'Capture': 'ছবি তুলুন',
    'Could not capture photo': 'ছবি তোলা যায়নি',

    // Ruler
    'Calibrate ruler': 'রুলার ক্যালিব্রেট',
    'Place a bank / ID card on the screen and drag the slider until the box matches the short edge of the card (54 mm).':
        'একটি ব্যাংক / আইডি কার্ড স্ক্রিনে রাখুন এবং স্লাইডার টেনে বক্সটি কার্ডের ছোট দিকের (৫৪ মিমি) সমান করুন।',
    'Done': 'সম্পন্ন',
    'Drag the marker to measure': 'মাপতে মার্কার টানুন',

    // Slope
    'Lay the phone on the slope to read its angle, grade and roof pitch.':
        'ঢালের কোণ, গ্রেড ও ছাদের পিচ জানতে ফোনটি ঢালের উপর রাখুন।',
    'Angle': 'কোণ',
    'Grade': 'গ্রেড',
    'Roof pitch': 'ছাদের পিচ',
    'Ratio': 'অনুপাত',

    // Height
    'Height': 'উচ্চতা',
    'Distance': 'দূরত্ব',
    'Phone height (m)': 'ফোনের উচ্চতা (মি)',
    '1. Aim the crosshair at the BASE of the object and tap the button.':
        '১. ক্রসহেয়ার বস্তুর নিচের অংশে তাক করে বাটনে চাপুন।',
    '2. Aim the crosshair at the TOP of the object and tap the button.':
        '২. ক্রসহেয়ার বস্তুর উপরের অংশে তাক করে বাটনে চাপুন।',
    'Mark base': 'নিচ চিহ্নিত করুন',
    'Mark top': 'উপর চিহ্নিত করুন',
    'Measure again': 'আবার মাপুন',
    'Aim below the horizon for the base.':
        'নিচের অংশের জন্য দিগন্তের নিচে তাক করুন।',

    // Sound
    'Microphone permission is required to measure sound.':
        'শব্দ মাপতে মাইক্রোফোন পারমিশন লাগবে।',
    'Min': 'সর্বনিম্ন',
    'Avg': 'গড়',
    'Max': 'সর্বোচ্চ',
    'Approximate values — phone microphones are not calibrated sound meters.':
        'আনুমানিক মান — ফোনের মাইক্রোফোন প্রকৃত শব্দ মাপক নয়।',
    'Quiet': 'শান্ত',
    'Normal conversation': 'সাধারণ কথাবার্তা',
    'Busy traffic': 'ব্যস্ত রাস্তা',
    'Loud — limit exposure': 'উচ্চ শব্দ — বেশিক্ষণ থাকবেন না',
    'Dangerous': 'বিপজ্জনক',

    // Metal
    'Move the top of the phone slowly along the wall or surface.':
        'ফোনের উপরের অংশ ধীরে ধীরে দেয়াল বা জিনিসের উপর দিয়ে সরান।',
    'Metal detected!': 'মেটাল পাওয়া গেছে!',
    'No metal nearby': 'কাছে কোনো মেটাল নেই',
    'Calibrate away from metal': 'মেটাল থেকে দূরে রেখে ক্যালিব্রেট করুন',

    // Surface
    'Place the phone flat on the surface.': 'ফোনটি সমতলে রাখুন।',
    'Surface is level': 'সারফেস সমান আছে',
  };

  static String tr(String key) {
    if (!isBangla) return key;
    return _bn[key] ?? key;
  }
}

/// Shorthand for [AppStrings.tr].
String tr(String key) => AppStrings.tr(key);
