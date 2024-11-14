import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
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
  await initStore();

  personRepo = PersonRepository(store);
  vehicleRepo = VehicleRepository(store);
  parkingSpaceRepo = ParkingSpaceRepository(store);
  parkingRepo = ParkingRepository(store, parkingSpaceRepo);

  final persons = await personRepo.getAll();
  final vehicles = await vehicleRepo.getAll();
  final parkings = await parkingRepo.getAll();
  final parkingSpaces = await parkingSpaceRepo.getAll();
  final jsonPersons = persons.map((p) => p.toJson()).toList();
  final jsonVehicles = vehicles.map((v) => v.toJson()).toList();
  final jsonParkings = parkings.map((p) => p.toJson()).toList();
  final jsonParkingSpaces = parkingSpaces.map((ps) => ps.toJson()).toList();

  startServerInIsolate(
      jsonPersons, jsonVehicles, jsonParkings, jsonParkingSpaces);
}

Future<void> initStore() async {
  store = openStore();
}

// Funktion för att starta servern i ett separat isolat
void startServerInIsolate(
    List<Map<String, dynamic>> persons,
    List<Map<String, dynamic>> vehicles,
    List<Map<String, dynamic>> parkings,
    List<Map<String, dynamic>> parkingSpaces) {
  final receivePort = ReceivePort();
  final params = ServerIsolateParams(
    sendPort: receivePort.sendPort,
    persons: persons,
    vehicles: vehicles,
    parkings: parkings,
    parkingSpaces: parkingSpaces,
  );

  Isolate.spawn(startServer, params);

  receivePort.listen((message) {
    // print("Meddelande från isolat: $message");
  }).onDone(() {
    receivePort.close();
  });
}

// Funktion för att starta servern som körs i isolatet
Future<void> startServer(ServerIsolateParams params) async {
  final SendPort sendPort = params.sendPort;
  final List<Map<String, dynamic>> persons = params.persons;
  final List<Map<String, dynamic>> vehicles = params.vehicles;
  final List<Map<String, dynamic>> parkings = params.parkings;
  final List<Map<String, dynamic>> parkingSpaces = params.parkingSpaces;

  final appRouter = Router();

  appRouter.get('/', (Request req) => Response.ok('Server is up and running!'));

  // Skapa rutter för personer
  appRouter.get('/persons', (Request req) async {
    //TODO: get all persons from person repository

    return Response.ok(
      jsonEncode(persons),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Skapa rutter för fordon
  appRouter.get('/vehicles', (Request req) async {
    //TODO: get all vehicles from person repository

    return Response.ok(
      jsonEncode(vehicles),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Skapa rutter för parkeringar
  appRouter.get('/parkings', (Request req) async {

    //TODO: get all parkings from person repository


    return Response.ok(
      jsonEncode(parkings),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Skapa rutter för parkeringsplatser
  appRouter.get('/parkingSpaces', (Request req) async {

    //TODO : ...

    return Response.ok(
      jsonEncode(parkingSpaces),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // TODO: add routes (from specification)

  // TODO: check https://github.com/williamviktorsson/HFL24/tree/main/assignment_code/assignment_2_almost_finished_example/objectbox

  /* 
  
  Route	HTTP-metod	Beskrivning	Repository-metod
/persons	GET	Hämta alla personer	getAll()
/persons	POST	Skapa ny person	create()
/persons/<id>	GET	Hämta specifik person	getById()
/persons/<id>	PUT	Uppdatera specifik person	update()
/persons/<id>	DELETE	Ta bort specifik person	delete()
/vehicles	GET	Hämta alla fordon	getAll()
/vehicles	POST	Skapa nytt fordon	create()
/vehicles/<id>	GET	Hämta specifikt fordon	getById()
/vehicles/<id>	PUT	Uppdatera specifikt fordon	update()
/vehicles/<id>	DELETE	Ta bort specifikt fordon	delete()
/parkingspaces	GET	Hämta alla parkeringsplatser	getAll()
/parkingspaces	POST	Skapa ny parkeringsplats	create()
/parkingspaces/<id>	GET	Hämta specifik parkeringsplats	getById()
/parkingspaces/<id>	PUT	Uppdatera parkeringsplats	update()
/parkingspaces/<id>	DELETE	Ta bort parkeringsplats	delete()
/parkings	GET	Hämta alla parkeringar	getAll()
/parkings	POST	Skapa ny parkering	create()
/parkings/<id>	GET	Hämta specifik parkering	getById()
/parkings/<id>	PUT	Uppdatera specifik parkering	update()
/parkings/<id>	DELETE	Ta bort specifik parkering	delete()
  
   */

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(appRouter.call);

  try {
    server = await io.serve(handler, 'localhost', 8080);
    print('Server started successfully on port 8080');
    sendPort.send('Server started on port 8080');
  } catch (e) {
    print('Fel vid start av servern: $e');
    sendPort.send('Failed to start server: $e');
  }
}

// Funktion för att stoppa servern
Future<void> stopServer() async {
  await server?.close();
  print('Server stopped.');
}
