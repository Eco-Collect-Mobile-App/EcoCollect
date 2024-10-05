// waste_data.dart
class WasteData {
  final String name;
  final String nic;
  final DateTime date;
  final int organic;
  final int plastic;
  final int recyclable;
  final int other;

  WasteData({
    required this.name,
    required this.nic,
    required this.date,
    required this.organic,
    required this.plastic,
    required this.recyclable,
    required this.other,
  });
}
