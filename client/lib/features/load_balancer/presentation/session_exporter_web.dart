import 'package:web/web.dart' as web;

class SessionExporterWeb {
  const SessionExporterWeb();

  void downloadText({
    required String filename,
    required String mimeType,
    required String content,
  }) {
    final encoded = Uri.encodeComponent(content);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = 'data:$mimeType;charset=utf-8,$encoded'
      ..download = filename;

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }
}
