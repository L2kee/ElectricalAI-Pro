/// Web build: a plain same-tab navigation, like any link on the site.
library;

import 'dart:js_interop';

@JS('window.location.assign')
external void _assign(JSString url);

const bool available = true;

void open(String url) => _assign(url.toJS);
