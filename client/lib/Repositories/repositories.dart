import 'package:mycarparkingapp/Repositories/person_repository.dart';
import 'package:mycarparkingapp/Repositories/vehicle_repository.dart';
import 'package:mycarparkingapp/Repositories/parking_space_repository.dart';
import 'package:mycarparkingapp/Repositories/parking_repository.dart';
import 'package:shared/shared.dart';

class Repositories {
  final PersonRepository personRepo;
  final VehicleRepository vehicleRepo;
  final ParkingSpaceRepository parkingSpaceRepo;
  late final ParkingRepository parkingRepo;

  // Konstruktor
  Repositories(Store store)
      : personRepo = PersonRepository(store),
        vehicleRepo = VehicleRepository(store),
        parkingSpaceRepo = ParkingSpaceRepository(store) {
          
    // Initierar parkingRepo efter att parkingSpaceRepo är skapad
    parkingRepo = ParkingRepository(store, parkingSpaceRepo);
  }
}




