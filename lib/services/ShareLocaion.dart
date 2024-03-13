import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/pages/mapView.dart';
import 'package:url_launcher/url_launcher_string.dart';

class shareLoc {
  static Future<void> createDynamicLink(LatLng latLng) async {
    print(
        "createing Dynamic Link lat: ${latLng.latitude} long:  ${latLng.longitude}");
    String link =
        'https://mishkat.page.link/latitude=${latLng.latitude}/longitude=${latLng.longitude}';

    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(link),
      uriPrefix: 'https://mishkat.page.link',
      androidParameters: AndroidParameters(
          packageName: 'com.example.mishkat',
          fallbackUrl: Uri.parse('https://androidapp.link')), //live url
    );
    print("long link : " + Uri.parse(link).toString());
    var shortlink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    _launchWhatsApp(shortlink.shortUrl);
    print(" Link Genrated : ${shortlink.shortUrl}");
    print(" Link Genrated : ${link}");
  }

//  static Future<void> handleDynamicLinks(BuildContext context) async {
//     FirebaseDynamicLinks.instance.onLink(
//       onSuccess: (PendingDynamicLinkData dynamicLink) async {
//         Uri deepLink = dynamicLink?.link;
//         if (deepLink != null) {
//           // Handle the deep link here
//           handleDeepLink(context, deepLink);
//         }
//       },
//       onError: (OnLinkErrorException e) async {
//         print('Error handling dynamic link: ${e.message}');
//       },
//     );

//     // Get the initial dynamic link if the app was opened with a dynamic link
//     final PendingDynamicLinkData initialLink =
//         await FirebaseDynamicLinks.instance.getInitialLink();
//     final Uri deepLink = initialLink?.link;

//     if (deepLink != null) {
//       // Handle the deep link here as well
//       handleDeepLink(context, deepLink);
//     }
//   }

//   static void handleDeepLink(BuildContext context, Uri deepLink) {
//     // Extract latitude and longitude from the deep link
//     String latitude = deepLink.queryParameters['lat'];
//     String longitude = deepLink.queryParameters['long'];

//     // Use latitude and longitude as needed
//     print('Latitude: $latitude, Longitude: $longitude');

//     // Navigate to the MapView screen with the extracted data
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapViewScreen(
//           latitude: double.parse(latitude),
//           longitude: double.parse(longitude),
//         ),
//       ),
//     );
//   }

  static var latitude = "";
  static var longitude = "";
  late LatLng coordinates;
  static var preLink = null;
  static Future<void> handleDynamicLinks(BuildContext context) async {
    bool isfirst = true;

    await FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData? dynamicLink) async {
        final Uri? deepLink = dynamicLink?.link;

        String deepLinkStr = deepLink.toString();

        print("Received link latitude: $latitude");
        print("Received link longitude: $longitude");
        print("Received link: $deepLink");

        if (deepLink != null) {
          if (isfirst) {
            isfirst = false;
            latitude = deepLinkStr.substring(
              deepLinkStr.indexOf('=') + 1,
              deepLinkStr.indexOf('/', deepLinkStr.indexOf('=')),
            );

            longitude = deepLinkStr.substring(
              deepLinkStr.indexOf('=', deepLinkStr.indexOf('=') + 1) + 1,
            );

            print("Received link latitude YEEEESSSS: $latitude");
            print("Received link longitude: $longitude");
            print("Received link: $deepLink");

            LatLng coordinates =
                LatLng(double.parse(latitude), double.parse(longitude));

            // Use Navigator without passing the context
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  center: coordinates,
                ),
              ),
            );
          }
        }
      },
      onDone: () {
        print("done");
      },
      onError: (e) async {
        // Handle errors related to dynamic links here
      },
    );
  }
}

class Context {}

void _launchWhatsApp(msg) async {
  var link = "My Loaction is at    \n$msg ";

  String url = "https://wa.me/?text=$link";
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    _launchURL();
  }
}

void _launchURL() async {
  const url = 'https://play.google.com/store/apps/details?id=com.whatsapp';
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}
