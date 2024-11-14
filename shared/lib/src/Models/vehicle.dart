import 'package:objectbox/objectbox.dart';

@Entity()
class Vehicle {
  @Id()
  int id = 0; 

  @Unique()
  String registrationNumber; 
  String model; 
  int ownerId;
  String ownerPersonNumber;
  String color;
  int? year;

  Vehicle({
    this.id = 0,
    required this.registrationNumber, 
    required this.model,
    required this.ownerId,
    required this.ownerPersonNumber,
    required this.color,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
      id: json['id'] ?? 0,
      registrationNumber: json['registrationNumber'], 
      model: json['model'],
      ownerId: json['ownerId'],
      ownerPersonNumber: json['ownerPersonNumber'],
      color: json['color'],
      year: json['year']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'registrationNumber': registrationNumber, 
        'model': model,
        'ownerId': ownerId,
        'ownerPersonNumber': ownerPersonNumber,
        'color': color,
        'year': year,
      };

  @override
  String toString() {
    return 'ID: $id, Registreringsnummer: $registrationNumber, model: $model, Färg: $color, Årsmodell: $year';
  }
}