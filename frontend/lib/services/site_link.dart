/// Navigation back to evogencyglobal.com. Only the web build lives on the
/// site, so the desktop build has no link to show (see [SiteLink.available]).
library;

import 'site_link_stub.dart' if (dart.library.js_interop) 'site_link_web.dart' as impl;

class SiteLink {
  SiteLink._();

  /// The EVOGENCY homepage.
  static final Uri home = Uri.parse('https://evogencyglobal.com/');

  /// True on the web build.
  static bool get available => impl.available;

  /// Opens [url] in the current tab.
  static void open(Uri url) => impl.open(url.toString());
}
