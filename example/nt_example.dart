import 'package:nt/nt.dart';

void main() {
  // Obtain an instance of a NetworkTable at /datatable
  NetworkTable table = NetworkTables.getTable("datatable");

  // Get the entries within that table that correspond
  // to the x and y values. These can be found at
  // `/datatable/x` and `/datatable/y`
  NetworkTableEntry xEntry = table.getEntry("x");
  NetworkTableEntry yEntry = table.getEntry("y");

  // Set the values of the entries
  xEntry.setDouble(5);
  yEntry.setDouble(3);

  // Read the values from the entries and print them out
  print(xEntry.getDouble());
  print(yEntry.getDouble());
}
