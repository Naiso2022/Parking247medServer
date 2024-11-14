import 'package:objectbox/objectbox.dart';


@Entity()
class ParkingSpace {
  @Id()
  int id = 0; 
  String address;
  double pricePerHour;

  ParkingSpace({
    this.id = 0,
    required this.address,
    required this.pricePerHour,
  });

  factory ParkingSpace.fromJson(Map<String, dynamic> json) => ParkingSpace(
        id: json['id'] ?? 0,
        address: json['address'],
        pricePerHour: json['pricePerHour'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'pricePerHour': pricePerHour,
      };

  @override
  String toString() {
    return 'ID: $id, Adress: $address, Pris per timme: $pricePerHour SEK';
  }
}