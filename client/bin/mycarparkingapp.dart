import 'dart:convert';
import 'dart:io';
import 'dart:isolate'; 
import 'package:mycarparkingapp/cli.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:mycarparkingapp/Repositories/person_repository.dart';
import 'package:mycarparkingapp/Repositories/vehicle_repository.dart';
import 'package:mycarparkingapp/Repositories/parking_space_repository.dart';
import 'package:mycarparkingapp/Repositories/parking_repository.dart';

import 'dart:async';

late Store store;
HttpServer? server;


late PersonRepository personRepo;
late VehicleRepository vehicleRepo;
late ParkingSpaceRepository parkingSpaceRepo;
late ParkingRepository parkingRepo;


class ServerIsolateParams {
  final SendPort sendPort;
  final List<Map<String, dynamic>> persons;
  final List<Map<String, dynamic>> vehicles;
  final List<Map<String, dynamic>> parkings;
  final List<Map<String, dynamic>> parkingSpaces;

  ServerIsolateParams({
    required this.sendPort,
    required this.persons,
    required this.vehicles,
    required this.parkings,
    required this.parkingSpaces,
  });
}

Future<void> main() async {

  personRepo = PersonRepository(store);
  vehicleRepo = VehicleRepository(store);
  parkingSpaceRepo = ParkingSpaceRepository(store);
  parkingRepo = ParkingRepository(store, parkingSpaceRepo);


  // Starta CLI-flödet
  startCliFlow(personRepo, vehicleRepo, parkingSpaceRepo, parkingRepo);
}
