// Dart imports:
import "dart:io" show Platform;

// Flutter imports:
import "package:flutter/foundation.dart";

// Package imports:
import "package:url_launcher/url_launcher.dart";

enum Link { website, store, github, email }

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries.map((MapEntry<String, String> e) => "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}").join("&");
}

final Uri websiteLaunchUri = Uri.parse("https://nightdreamgames.com/");
final Uri playStoreLaunchUri = Uri.https("play.google.com", "/store/apps/details", {"id": "com.NightDreamGames.Grade.ly"});
final Uri appStoreLaunchUri = Uri.parse("https://apps.apple.com/us/app/graded-suivi-de-notes/id6444681284");
final Uri githubLaunchUri = Uri.parse("https://github.com/NightDreamGames/Graded");
final Uri emailLaunchUri = Uri(
  scheme: "mailto",
  path: "contact@nightdreamgames.com",
  query: encodeQueryParameters(<String, String>{
    "subject": "Graded feedback",
    "body": "Thank you for your feedback!",
  }),
);

Future<void> launchURL(Link type) async {
  Uri link = websiteLaunchUri;

  switch (type) {
    case Link.website:
      link = websiteLaunchUri;
    case Link.store:
      if (isAndroid) {
        link = playStoreLaunchUri;
      } else if (isiOS) {
        link = appStoreLaunchUri;
      } else {
        link = websiteLaunchUri;
      }
    case Link.github:
      link = githubLaunchUri;
    case Link.email:
      link = emailLaunchUri;
  }

  if (!await launchUrl(
    link,
    mode: LaunchMode.externalApplication,
  )) {
    throw "Error while opening link: $link";
  }
}

bool isAndroid = !kIsWeb && Platform.isAndroid;
bool isiOS = !kIsWeb && Platform.isIOS;
bool isWeb = kIsWeb;
