import 'package:url_launcher/url_launcher.dart';
import 'package:stack_trace/stack_trace.dart';

class Misc {
  static Future<void> callPhone(phone, {Function onFailure}) async {
    String url = 'tel://${phone.replaceAll(RegExp(r'\s|\(|\)|\-'), '')}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      onFailure?.call();
    }
  }

  static Map<String, String> stackFrame(int frame) {
    List<String> frameData = Trace.current().frames[frame + 1].member.split('.');

    return {
      'className': frameData[0],
      'methodName': frameData[1],
    };
  }
}
