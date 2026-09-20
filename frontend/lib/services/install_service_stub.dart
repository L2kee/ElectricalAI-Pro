/// Non-web fallback (desktop builds) - there's no browser install prompt
/// to offer, so every call is a safe no-op.
library;

bool canAutoInstall() => false;

bool isIOS() => false;

bool isStandalone() => false;

Future<String> promptInstall() async => 'unavailable';
