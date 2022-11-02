import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:nt/gen/ntcore.dart';
import 'package:nt/src/ntcore.dart';

String _charPointerToString(Pointer<Char> value, int length) {
  final units = List<int>.empty(growable: true);
  for (var i = 0; i < length; i++) {
    units.add(value.elementAt(i).cast<Int8>().value);
  }
  return String.fromCharCodes(units);
}

Pointer<Uint8> _intListToIntPointer(List<int> value) {
  final ptr = malloc.allocate<Uint8>(sizeOf<Uint8>() * value.length);
  for (var i = 0; i < value.length; i++) {
    ptr.elementAt(i).value = value[i].toUnsigned(8);
  }
  return ptr;
}

enum NetworkTablesVersion {
  v3,
  v4,
}

class NetworkTables {
  static final int instanceHandle = nt.NT_GetDefaultInstance();

  /// Establish a networktables client and connect to the server.
  static void connect(String server,
      {int port = 1735,
      String name = "Dart NT",
      NetworkTablesVersion version = NetworkTablesVersion.v4}) {
    if (version == NetworkTablesVersion.v3) {
      nt.NT_StartClient3(instanceHandle, name.toNativeUtf8().cast());
    } else if (version == NetworkTablesVersion.v4) {
      nt.NT_StartClient4(instanceHandle, name.toNativeUtf8().cast());
    } else {
      throw Exception("This should not be possible to be seen. Report me!");
    }
    nt.NT_SetServer(instanceHandle, server.toNativeUtf8().cast(), port);
  }

  static void startServer(String server,
      {int port = 1735, String persistentFile = "networktables.ini"}) {
    nt.NT_StartServer(instanceHandle, persistentFile.toNativeUtf8().cast(),
        server.toNativeUtf8().cast(), port, port + 1);
  }

  static void stopServer() {
    nt.NT_StopServer(instanceHandle);
  }

  /// Gets a table.
  ///
  /// Will use the key at /$path
  ///
  /// @name The name of the table
  static NetworkTable getTable(String name) {
    return NetworkTable('/$name');
  }

  /// Gets a base level entry.
  ///
  /// Will use the key at /$name
  ///
  /// @name The name of the entry to reference
  static NetworkTableEntry getEntry(String name) {
    return NetworkTableEntry('/$name');
  }
}

class NetworkTable {
  String path;

  NetworkTable(this.path);

  /// Gets a subtable.
  ///
  /// Will use the key at /$path/$name
  ///
  /// @name The name of the subtable
  NetworkTable getTable(String name) {
    return NetworkTable('/$name');
  }

  /// Gets an entry at the specified name.
  ///
  /// Will use the key at /$path/$name
  ///
  /// @name The name of the entry to reference
  NetworkTableEntry getEntry(String name) {
    return NetworkTableEntry('$path/$name');
  }
}

class NetworkTableEntry {
  String path;
  late int _entryHandle;

  NetworkTableEntry(this.path) {
    _entryHandle = nt.NT_GetEntry(
        NetworkTables.instanceHandle, path.toNativeUtf8().cast(), path.length);
  }

  /// Set a double value at the key specified on the entry.
  void setDouble(double value) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    valuePointer.ref.data = calloc<UnnamedUnion1>().ref;
    valuePointer.ref.data.v_double = value;
    valuePointer.ref.type = NT_Type.NT_DOUBLE;
    nt.NT_SetEntryValue(_entryHandle, valuePointer);
  }

  /// Get the double value at the key.
  ///
  /// @defaultValue If there is no value at the key already,
  /// return a default instead.
  double getDouble({double defaultValue = 0}) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    nt.NT_GetEntryValue(_entryHandle, valuePointer);
    if (valuePointer.ref.type == NT_Type.NT_DOUBLE) {
      return valuePointer.ref.data.v_double;
    } else if (valuePointer.ref.type != NT_Type.NT_UNASSIGNED) {
      throw Exception("Cannot parse double from $path.");
    }
    return defaultValue;
  }

  /// Set the float value at the key.
  ///
  /// Technically takes a double still, but when stored
  /// in NetworkTables, it's interpreted as a float.
  void setFloat(double value) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    valuePointer.ref.data = calloc<UnnamedUnion1>().ref;
    valuePointer.ref.data.v_float = value;
    valuePointer.ref.type = NT_Type.NT_FLOAT;
    nt.NT_SetEntryValue(_entryHandle, valuePointer);
  }

  /// Get the float value at the key.
  ///
  /// Technically returns a double still, but when stored
  /// in NetworkTables, it's interpreted as a float.
  ///
  /// @defaultValue If there is no value at the key already,
  /// return a default instead.
  double getFloat({double defaultValue = 0}) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    nt.NT_GetEntryValue(_entryHandle, valuePointer);
    if (valuePointer.ref.type == NT_Type.NT_FLOAT) {
      return valuePointer.ref.data.v_float;
    } else if (valuePointer.ref.type != NT_Type.NT_UNASSIGNED) {
      throw Exception("Cannot parse float from $path.");
    }
    return defaultValue;
  }

  /// Set the int value at the key.
  void setInt(int value) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    valuePointer.ref.data = calloc<UnnamedUnion1>().ref;
    valuePointer.ref.data.v_int = value;
    valuePointer.ref.type = NT_Type.NT_INTEGER;
    nt.NT_SetEntryValue(_entryHandle, valuePointer);
  }

  /// Get the int value at the key.
  ///
  /// @defaultValue If there is no value at the key already,
  /// return a default instead.
  int getInt({int defaultValue = 0}) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    nt.NT_GetEntryValue(_entryHandle, valuePointer);
    if (valuePointer.ref.type == NT_Type.NT_INTEGER) {
      return valuePointer.ref.data.v_int;
    } else if (valuePointer.ref.type != NT_Type.NT_UNASSIGNED) {
      throw Exception("Cannot parse int from $path.");
    }
    return defaultValue;
  }

  /// Sets a string value at the key.
  void setString(String value) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();

    final Pointer<NT_String> stringPointer = calloc<NT_String>();
    stringPointer.ref.str = value.toNativeUtf8().cast();
    stringPointer.ref.len = value.length;

    valuePointer.ref.data = calloc<UnnamedUnion1>().ref;
    valuePointer.ref.data.v_string = stringPointer.ref;
    valuePointer.ref.type = NT_Type.NT_STRING;
    nt.NT_SetEntryValue(_entryHandle, valuePointer);
  }

  /// Gets the string value at the key.
  ///
  /// @defaultValue If there is no value at the key already,
  /// return a default instead.
  String getString({String defaultValue = ""}) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    nt.NT_GetEntryValue(_entryHandle, valuePointer);
    if (valuePointer.ref.type == NT_Type.NT_STRING) {
      Pointer<Char> stringPointer = valuePointer.ref.data.v_string.str;
      return _charPointerToString(
          stringPointer, valuePointer.ref.data.v_string.len);
    } else if (valuePointer.ref.type != NT_Type.NT_UNASSIGNED) {
      throw Exception("Cannot parse string from $path.");
    }
    return defaultValue;
  }

  void setRaw(List<int> value) {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();

    final Pointer<UnnamedStruct1> rawPointer = calloc<UnnamedStruct1>();
    rawPointer.ref.data = _intListToIntPointer(value);
    rawPointer.ref.size = value.length;

    valuePointer.ref.data = calloc<UnnamedUnion1>().ref;
    valuePointer.ref.data.v_raw = rawPointer.ref;
    valuePointer.ref.type = NT_Type.NT_RAW;
    nt.NT_SetEntryValue(_entryHandle, valuePointer);
  }

  List<int> getRaw() {
    final Pointer<NT_Value> valuePointer = calloc<NT_Value>();
    nt.NT_GetEntryValue(_entryHandle, valuePointer);
    if (valuePointer.ref.type == NT_Type.NT_RAW) {
      UnnamedStruct1 bytes = valuePointer.ref.data.v_raw;
      List<int> data = List.empty(growable: true);
      for (var i = 0; i < bytes.size; i++) {
        data.add(bytes.data.elementAt(i).value);
      }
      return data;
    } else if (valuePointer.ref.type != NT_Type.NT_UNASSIGNED) {
      throw Exception("Cannot parse string from $path.");
    }
    return List.empty();
  }
}
