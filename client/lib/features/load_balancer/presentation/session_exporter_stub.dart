class SessionExporterWeb {
  const SessionExporterWeb();

  void downloadText({
    required String filename,
    required String mimeType,
    required String content,
  }) {
    throw UnsupportedError('Session export is only available in a browser.');
  }
}
