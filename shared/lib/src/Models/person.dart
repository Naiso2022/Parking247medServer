import 'package:objectbox/objectbox.dart';


@Entity()
class Person {
  @Id()
  int id = 0; 
  String? personNumber;
  String? firstName;
  String? lastName;

  Person(
      {this.id = 0,
      this.personNumber,
      this.firstName,
      this.lastName});

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] ?? 0,
        personNumber: json['personNumber'] ?? '', 
        firstName: json['firstName'] ?? '', 
        lastName: json['lastName'] ?? '', 
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'personNumber': personNumber,
        'firstName': firstName,
        'lastName': lastName,
      };

  String get namn => '$firstName $lastName';
}