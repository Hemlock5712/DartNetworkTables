import 'dart:ffi';
import 'package:dylib/dylib.dart';
import 'package:glob/glob.dart';
import 'dart:io';

import 'package:nt/gen/ntcore.dart';

Glob ntcoreGlob = Glob("allwpilib/ntcoreffi/build/**/release");

String NTCORE_PATH = Directory.current
    .listSync()
    .where((f) => ntcoreGlob.matches(f.path))
    .elementAt(0)
    .path;

// const NTCORE_PATH =
//     "allwpilib/ntcoreffi/build/libs/ntcoreffi/shared/osxx86-64/release";

ntcore get nt {
  return ntcore(DynamicLibrary.open(resolveDylibPath('libntcoreffi',
      dartDefine: 'LIBNTCORE_PATH',
      environmentVariable: 'LIBNTCORE_PATH',
      path: NTCORE_PATH)));
}
