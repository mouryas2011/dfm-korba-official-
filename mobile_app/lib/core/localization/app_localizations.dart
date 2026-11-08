import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'DFM Korba Official',
      'tagline': 'Skill Development Learning & Competition Platform',
      'choose_role': 'Choose Your Role',
      'student': 'Student',
      'student_sub': 'Learn & Practice',
      'teacher': 'Teacher',
      'teacher_sub': 'Manage & Evaluate',
      'team': 'Team',
      'team_sub': 'Collaborate & Compete',
      'admin': 'Admin',
      'admin_sub': 'Control & Monitor',
      'login': 'Login',
      'contact_teacher': 'New Student? Contact your Teacher',
      'mobile_number': 'Mobile Number / Team ID',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'home': 'Home',
      'courses': 'Courses',
      'gallery': 'Gallery',
      'compete': 'Compete',
      'more': 'More',
      'dashboard': 'Dashboard',
      'learning': 'Learning',
      'tasks': 'Tasks',
      'chat': 'Chat',
      'profile': 'Profile',
      'my_progress': 'My Progress',
      'top_team_of_week': 'Top Team of the Week',
      'top_students': 'Top 5 Students',
      'submit_work': 'Submit Your Work',
      'upload_work_desc': 'Video, Image, PDF, PPT, DOC, Audio (Max 500 MB)',
      'add_contribution': 'Add Your Contribution',
      'contribution_hint': 'Describe what you have done in this task...',
      'submit_task': 'Submit Task',
      'attendance': 'Attendance',
      'daily_review': 'Daily Company Review',
      'ai_quiz': 'AI Quiz (15 Days)',
      'performance': 'Performance',
      'marks': 'Marks',
      'members': 'Members',
      'score': 'Score',
      'take_quiz': 'Start Quiz',
      'question': 'Question',
      'submit_answers': 'Submit Answers',
      'change_temp_password': 'Change Temporary Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      'update_password': 'Update Password & Enter',
      'register_student': 'Register New Student',
      'send_whatsapp': 'Send WhatsApp Welcome',
      'copy_credentials': 'Copy Credentials',
    },
    'hi': {
      'app_title': 'डीएफएम कोरबा ऑफिशियल',
      'tagline': 'कौशल विकास शिक्षण एवं प्रतियोगिता प्रबंधन मंच',
      'choose_role': 'अपनी भूमिका चुनें',
      'student': 'विद्यार्थी (Student)',
      'student_sub': 'सीखें और अभ्यास करें',
      'teacher': 'शिक्षक (Teacher)',
      'teacher_sub': 'प्रबंधन एवं मूल्यांकन',
      'team': 'टीम (Team)',
      'team_sub': 'सहयोग और प्रतिस्पर्धा',
      'admin': 'प्रशासक (Admin)',
      'admin_sub': 'नियंत्रण एवं निगरानी',
      'login': 'लॉग इन करें',
      'contact_teacher': 'नए विद्यार्थी? अपने शिक्षक से संपर्क करें',
      'mobile_number': 'मोबाइल नंबर / टीम आईडी',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड भूल गए?',
      'home': 'मुख्य पृष्ठ',
      'courses': 'पाठ्यक्रम',
      'gallery': 'गैलरी',
      'compete': 'प्रतियोगिता',
      'more': 'अधिक',
      'dashboard': 'डैशबोर्ड',
      'learning': 'अध्ययन सामग्री',
      'tasks': 'कार्य (Tasks)',
      'chat': 'चैट',
      'profile': 'प्रोफ़ाइल',
      'my_progress': 'मेरी प्रगति',
      'top_team_of_week': 'सप्ताह की शीर्ष टीम',
      'top_students': 'शीर्ष 5 विद्यार्थी',
      'submit_work': 'अपना कार्य जमा करें',
      'upload_work_desc': 'वीडियो, फोटो, PDF, PPT, DOC (अधिकतम 500 MB)',
      'add_contribution': 'अपना योगदान जोड़ें',
      'contribution_hint': 'वर्णन करें कि आपने इस कार्य में क्या किया...',
      'submit_task': 'कार्य जमा करें',
      'attendance': 'उपस्थिति',
      'daily_review': 'दैनिक समीक्षा रिपोर्ट',
      'ai_quiz': 'एआई क्विज़ (हर 15 दिन)',
      'performance': 'प्रदर्शन',
      'marks': 'अंक',
      'members': 'सदस्य',
      'score': 'स्कोर',
      'take_quiz': 'क्विज़ शुरू करें',
      'question': 'प्रश्न',
      'submit_answers': 'उत्तर जमा करें',
      'change_temp_password': 'अस्थायी पासवर्ड बदलें',
      'new_password': 'नया पासवर्ड',
      'confirm_password': 'पासवर्ड की पुष्टि करें',
      'update_password': 'पासवर्ड अपडेट करें',
      'register_student': 'नया विद्यार्थी पंजीकृत करें',
      'send_whatsapp': 'व्हाट्सएप आमंत्रण भेजें',
      'copy_credentials': 'क्रेडेंशियल्स कॉपी करें',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

