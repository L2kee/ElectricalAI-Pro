/// Web implementation - thin wrapper around the JS bridge functions
/// defined in web/index.html (window.eap*), which own the actual
/// `beforeinstallprompt` capture since that has to happen at the
/// browser/JS level before Dart ever starts running.
library;

import 'dart:js_interop';

@JS('eapCanAutoInstall')
external bool _canAutoInstall();

@JS('eapIsIOS')
external bool _isIOS();

@JS('eapIsStandalone')
external bool _isStandalone();

@JS('eapPromptInstall')
external JSPromise<JSString> _promptInstall();

bool canAutoInstall() => _canAutoInstall();

bool isIOS() => _isIOS();

bool isStandalone() => _isStandalone();

Future<String> promptInstall() async {
  final result = await _promptInstall().toDart;
  return result.toDart;
}
