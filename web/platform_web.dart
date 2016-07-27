// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library pop_pop_win.platform_web;

import 'dart:async';
import 'dart:html';

import 'package:pop_pop_win/platform_target.dart';

class PlatformWeb extends PlatformTarget {
  static const String _aboutHash = '#about';
  bool _sizeAccessed = false;

  final _aboutController = new StreamController<Null>(sync: true);

  PlatformWeb() : super.base() {
    window.onPopState.listen((args) => _processUrlHash());
  }

  @override
  Future clearValues() async => window.localStorage.clear();

  @override
  Future setValue(String key, String value) async =>
      window.localStorage[key] = value;

  @override
  Future<String> getValue(String key) async => window.localStorage[key];

  @override
  int get size {
    _sizeAccessed = true;
    var hash = (_urlHash == null) ? '7' : _urlHash;
    hash = hash.replaceAll('#', '');
    return int.parse(hash, onError: (e) => 7);
  }

  @override
  bool get showAbout => _urlHash == _aboutHash;

  @override
  Stream<Null> get aboutChanged => _aboutController.stream;

  @override
  void toggleAbout([bool value]) {
    var loc = window.location;
    // ensure we treat empty hash like '#', which makes comparison easy later
    var hash = loc.hash.length == 0 ? '#' : loc.hash;

    var isOpen = hash == _aboutHash;
    if (value == null) {
      // then toggle the current value
      value = !isOpen;
    }

    var targetHash = value ? _aboutHash : '#';
    if (targetHash != hash) {
      loc.assign(targetHash);
    }
    _aboutController.add(null);
  }

  String get _urlHash => window.location.hash;

  void _processUrlHash() {
    var loc = window.location;
    var hash = loc.hash;
    var href = loc.href;

    switch (hash) {
      case "#reset":
        assert(href.endsWith(hash));
        var newLoc = href.substring(0, href.length - hash.length);

        window.localStorage.clear();

        loc.replace(newLoc);
        break;
      case _aboutHash:
        _aboutController.add(null);
        break;
      default:
        if (hash.isNotEmpty && _sizeAccessed) {
          loc.reload();
        }
        break;
    }
  }
}
