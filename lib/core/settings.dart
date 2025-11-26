import 'package:mudkip_frontend/core/constants.dart';
import 'package:mudkip_frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// # `Class` Settings
/// ## A class that represents the settings of the application.
/// ### Constants:
/// - `defaultSettings`: The default settings of the application.
/// - `doPrefs`: Sets the default settings of the application.
/// - `setHeightChartGender`: Sets the gender of the height chart.
/// - `setHeightChartFormat`: Sets the format of the height chart.
/// - `heightChartGender`: Gets the gender of the height chart.
/// - `heightChartFormat`: Gets the format of the height chart.
/// - `resetToDefaults`: Resets the settings to the default settings.
/// - `resetHeightChart`: Resets the height chart to the default settings.
/// - `setEmptyToDefaults`: Sets the empty settings to the default settings.
/// - `hasUpdated`: Checks if the application has been updated.
class Settings {
  static late SharedPreferencesAsync prefs;
  static const Map<String, dynamic> defaultSettings = {
    "isHeightChartGenderMale": true,
    "isHeightChartFormatMetric": true
  };

  static Future<void> doPrefs() async {
    prefs = SharedPreferencesAsync();
    await setEmptyToDefaults();
    return;
  }

  static Future<void> setHeightChartGender(HeightChartGender value) async {
    await prefs.setBool(
        "isHeightChartGenderMale", value == HeightChartGender.male);
  }

  static Future<void> setHeightChartFormat(HeightChartFormat value) async {
    await prefs.setBool(
        "isHeightChartFormatMetric", value == HeightChartFormat.metric);
  }

  static Future<HeightChartGender> get heightChartGender async {
    bool? isMale = await prefs.getBool("isHeightChartGenderMale");
    if (isMale == true) {
      return HeightChartGender.male;
    } else {
      return HeightChartGender.female;
    }
  }

  static Future<HeightChartFormat> get heightChartFormat async {
    bool? isMetric = await prefs.getBool("isHeightChartFormatMetric");
    if (isMetric == true) {
      return HeightChartFormat.metric;
    } else {
      return HeightChartFormat.imperial;
    }
  }

  static Future<String> get heightChartFormatAsString async {
    if (await heightChartFormat == HeightChartFormat.metric) {
      return "Metric";
    } else {
      return "Imperial";
    }
  }

  static Future<String> get heightChartGenderAsString async {
    if (await heightChartGender == HeightChartGender.male) {
      return "Male";
    } else {
      return "Female";
    }
  }

  static Future<void> resetToDefaults() async {
    await prefs.clear();
    await setEmptyToDefaults();
    return;
  }

  static Future<void> setEmptyToDefaults() async {
    for (String key in defaultSettings.keys) {
      if (await prefs.containsKey(key)) {
        continue;
      }
      if (defaultSettings[key] is bool) {
        await prefs.setBool(key, defaultSettings[key] as bool);
      } else if (defaultSettings[key] is int) {
        await prefs.setInt(key, defaultSettings[key] as int);
      } else if (defaultSettings[key] is double) {
        await prefs.setDouble(key, defaultSettings[key] as double);
      } else if (defaultSettings[key] is String) {
        await prefs.setString(key, defaultSettings[key] as String);
      }
    }
    return;
  }

  static Future<bool> hasUpdated() async {
    if (await prefs.getString("version") == null) {
      await prefs.setString("version", packageInfo.buildNumber);
      return false;
    }
    if (await prefs.getString("version") != packageInfo.buildNumber) {
      List<int> originalVersion = (await prefs.getString("version"))!
          .split('.')
          .map((x) => int.parse(x))
          .toList();
      List<int> currentVersion =
          packageInfo.buildNumber.split('.').map((x) => int.parse(x)).toList();
      if (currentVersion[0] > originalVersion[0] ||
          currentVersion[1] > originalVersion[1] ||
          currentVersion[2] > originalVersion[2]) {
        await prefs.setString("version", packageInfo.buildNumber);
        return true;
      }
    }
    return false;
  }
}
