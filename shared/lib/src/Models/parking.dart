import 'package:objectbox/objectbox.dart';


@Entity()
class Parking {
  @Id()
  int id = 0;
  int vehicleId; 
  int parkingSpaceId; 
  @Property(type: PropertyType.date)
  DateTime startTime;
  @Property(type: PropertyType.date)
  DateTime? endTime; 

  Parking({
    required this.id,
    required this.vehicleId,
    required this.parkingSpaceId,
    required this.startTime,
    this.endTime,
  });

  factory Parking.fromJson(Map<String, dynamic> json) => Parking(
        id: json['id'] ?? 0,
        vehicleId: json['vehicleId'],
        parkingSpaceId: json['parkingSpaceId'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'parkingSpaceId': parkingSpaceId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  @override
  String toString() {
    String end = endTime != null ? endTime.toString() : 'Pågående';
    return 'ID: $id, Fordon ID: $vehicleId, Parkeringsplats ID: $parkingSpaceId, Starttid: $startTime, Sluttid: $end';
  }
}