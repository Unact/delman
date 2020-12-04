import 'package:url_launcher/url_launcher.dart';

class Misc {
  static Future<void> callPhone(phone, {Function onFailure}) async {
    String url = 'tel://${phone.replaceAll(RegExp(r'\s|\(|\)|\-'), '')}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      onFailure?.call();
    }
  }
}
