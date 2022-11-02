import 'package:nt/nt.dart';
import 'package:test/test.dart';

void main() {
  // Start a local server
  setUpAll(() {
    NetworkTables.startServer("localhost");
    NetworkTables.connect("localhost");
  });
  NetworkTable globalTable = NetworkTables.getTable("test");
  group('Doubles', () {
    NetworkTable table = globalTable.getTable("double");
    setUp(() {
      // Additional setup goes here.
      table.getEntry("real").setDouble(3.14);
    });

    test('should read a double value correctly', () {
      var entry = table.getEntry("real");
      expect(entry.getDouble(), 3.14);
    });

    test('should use the default value for invalid keys', () {
      var entry = table.getEntry("fake");
      expect(entry.getDouble(defaultValue: 3.14), 3.14);
    });
  });

  group('Ints', () {
    NetworkTable table = globalTable.getTable("int");
    setUp(() {
      table.getEntry("real").setInt(3);
    });

    test('should read a int value correctly', () {
      var entry = table.getEntry("real");
      expect(entry.getInt(), 3);
    });

    test('should use the default value for invalid keys', () {
      var entry = table.getEntry("fake");
      expect(entry.getInt(defaultValue: 3), 3);
    });
  });

  group('Strings', () {
    NetworkTable table = globalTable.getTable("string");
    setUp(() {
      table.getEntry("real").setString("Test");
    });

    test('should read a string value correctly', () {
      var entry = table.getEntry("real");
      expect(entry.getString(), "Test");
    });

    test("should use the default value for invalid keys", () {
      var entry = table.getEntry('fake');
      expect(entry.getString(defaultValue: "Default"), "Default");
    });
  });

  group("Raw", () {
    NetworkTable table = globalTable.getTable("raw");
    setUp(() {
      table.getEntry("real").setRaw(List.filled(4, 8));
    });

    test("should read a string value correctly", () {
      var entry = table.getEntry("real");
      expect(entry.getRaw(), List.filled(4, 8));
    });

    test("should use the default value for invalid keys", () {
      var entry = table.getEntry("fake");
      expect(entry.getRaw(), List.empty());
    });
  });

  tearDownAll(() {
    NetworkTables.stopServer();
  });
}
