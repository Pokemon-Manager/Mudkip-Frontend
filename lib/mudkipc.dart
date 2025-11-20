// Name: Pokemon Manager
// Purpose: The main file for the application, and exports all of the core classes and functions in the application.
// It also contains `MudkiPC` class, which is used for paths, preferences, and other important functions.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:queue/queue.dart';
import 'package:talker/talker.dart';

export 'src/import.dart';
export 'package:logging/logging.dart';

/// # `Class` MudkiPC
/// ## The main class for the application.
/// Contains functions for paths and other important functions.
class MudkiPC {
  static Queue queue = Queue(
      delay: const Duration(
          microseconds:
              10)); /* This queue is to make sure that multiple requests are not made at the same time, 
  as it could result in an overflow or an asynchronous error.*/
  static Future<String> get userFolder async {
    // Gets the path to the user's folder.
    return "${(await getApplicationDocumentsDirectory()).path}/MudkiPC/";
  }

  static Future<String> get cacheFolder async {
    // Gets the path to the cache folder, also known as the app data folder.
    return "${(await getApplicationCacheDirectory()).path}/MudkiPC/";
  }

  /// # static `Future<String?>` extractFileFromAssets(String path) async
  /// ## Extracts a file from the asset bundle, into the cache folder.
  /// Returns the path to the file.
  static Future<String?> extractFileFromAssets(String path,
      {bool overwrite = false}) async {
    if (path.startsWith("assets/")) {
      path = path.substring(7);
    }
    File globalFile = File(
        "${await MudkiPC.cacheFolder}$path"); // Initializes the file object to check if the database exists.
    if (!(globalFile.existsSync())) {
      ByteData data = await rootBundle
          .load("assets/$path"); // Loads the database from the asset bundle.
      globalFile.createSync(recursive: true); // Creates the file.
      globalFile.writeAsBytesSync(data.buffer
          .asUint8List()); // Writes the data from the asset bundle to the created file.
    } else {
      if (overwrite) {
        globalFile.writeAsBytesSync(
            (await rootBundle.load("assets/$path")).buffer.asUint8List());
      }
    }
    return globalFile.path;
  }

  static Future<bool> doesAssetFileExist(String path) async {
    if (path.startsWith("assets/")) {
      path = path.substring(7);
    }
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    if (!manifestMap.containsKey(path)) {
      return false;
    } else {
      return true;
    }
  }

  static Future<String?> getReyveldToken() async {
    final file = File("${await MudkiPC.cacheFolder}reyveld_token.txt");
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  static Future<void> setReyveldToken(String token) async {
    final file = File("${await MudkiPC.cacheFolder}reyveld_token.txt");
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(token);
    return;
  }

  static Talker? _talker;

  static Talker get talker => _talker ??= Talker();
}
