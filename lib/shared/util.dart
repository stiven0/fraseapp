import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

Future<void> openUrl( String url ) async {

  final Uri urlParsed = Uri.parse(url);
  await launchUrl(urlParsed);

}

Future<ShareResult> toShare( String text ) async  {

  return await Share.share(text);

}
