/// "Add to Home Screen" support. Only meaningful on web - this app also
/// ships as a Windows desktop build, which has no browser to install
/// itself into, so the real implementation only loads under
/// dart.library.js_interop and everything no-ops elsewhere.
library;

import 'install_service_stub.dart'
    if (dart.library.js_interop) 'install_service_web.dart' as impl;

class InstallService {
  InstallService._();

  /// True once the browser has offered a one-tap install (Chrome/Edge/
  /// Android). Never true on iOS Safari or desktop builds - there's no
  /// programmatic install trigger on either.
  static bool get canAutoInstall => impl.canAutoInstall();

  /// True on iOS Safari specifically, where "Add to Home Screen" only
  /// exists as a manual Share-sheet action Apple doesn't let any website
  /// trigger - the UI should show instructions instead of a button here.
  static bool get isIOS => impl.isIOS();

  /// True if already running as an installed/standalone app - nothing to
  /// offer in that case.
  static bool get isStandalone => impl.isStandalone();

  /// Shows the browser's real install prompt (Chrome/Edge/Android only).
  /// Returns 'accepted', 'dismissed', or 'unavailable' if no install
  /// prompt was ever captured.
  static Future<String> promptInstall() => impl.promptInstall();
}
