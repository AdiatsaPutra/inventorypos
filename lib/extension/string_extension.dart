import 'package:intl/intl.dart';

extension StringToDateTime on String {
  String toFormattedDate() {
    // Parse the string to DateTime
    DateTime dateTime = DateTime.parse(this);

    // Set up the desired date format and locale (Indonesian)
    final DateFormat formatter = DateFormat('d MMMM yyyy', 'id_ID');

    // Format the DateTime object to the required format
    return formatter.format(dateTime);
  }
}
