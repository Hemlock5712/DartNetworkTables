import 'dart:ffi';
import 'package:dylib/dylib.dart';

import 'package:nt/gen/ntcore.dart';

const NTCORE_PATH =
    "allwpilib/ntcoreffi/build/libs/ntcoreffi/shared/osxx86-64/release";

ntcore get nt {
  return ntcore(DynamicLibrary.open(resolveDylibPath('libntcoreffi',
      dartDefine: 'LIBNTCORE_PATH',
      environmentVariable: 'LIBNTCORE_PATH',
      path: NTCORE_PATH)));
}
