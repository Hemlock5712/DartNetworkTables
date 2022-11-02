import 'dart:ffi';

import 'package:nt/gen/ntcore.dart';

var nt = ntcore(DynamicLibrary.open(
    "./allwpilib/ntcoreffi/build/libs/ntcoreffi/shared/osxx86-64/release/libntcoreffi.dylib"));
