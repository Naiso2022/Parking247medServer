import 'dart:io';

import 'package:mycarparkingapp/Repositories/person_repository.dart';
import 'package:mycarparkingapp/Repositories/vehicle_repository.dart';
import 'package:mycarparkingapp/Repositories/parking_space_repository.dart';
import 'package:mycarparkingapp/Repositories/parking_repository.dart';
import 'dart:async';

import 'package:shared/shared.dart';

Future<void> startCliFlow(
  PersonRepository personRepo,
  VehicleRepository vehicleRepo,
  ParkingSpaceRepository parkingSpaceRepo,
  ParkingRepository parkingRepo,
) async {
  while (true) {
    print('Välkommen till Parkeringsappen!');
    print('Vad vill du hantera?');
    print('1. Personer');
    print('2. Fordon');
    print('3. Parkeringsplatser');
    print('4. Parkeringar');
    print('5. Avsluta');
    stdout.write('Välj ett alternativ (1-5): ');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        // Logik för att hantera personer
        await handlePersons(personRepo, vehicleRepo);
        break;

      case '2':
        // Logik för att hantera fordon
        await handleVehicles(vehicleRepo, personRepo);
        break;

      case '3':
        // Logik för att hantera parkeringsplatser
        await handleParkingSpaces(parkingSpaceRepo);
        break;

      case '4':
        // Logik för att hantera parkeringar
        await handleParkings(parkingRepo, vehicleRepo, parkingSpaceRepo);
        break;

      case '5':
        // Avslutar CLI-flödet
        print('Avslutar programmet...');
        exit(0); 

      default:
        print('Ogiltigt val, försök igen.');
    }
  }
}

Future<void> handlePersons(
    PersonRepository personRepo, VehicleRepository vehicleRepo) async {
  stdout.write(
      'Vad vill du göra med personer? (1: Skapa, 2: Visa, 3: Uppdatera, 4: Ta bort, 5: Visa persons fordon): ');
  String? action = stdin.readLineSync();

  switch (action) {
    case '1':
      // Skapa ny person
      String? firstName;
      String? lastName;
      String? personNumber;

      // Kontrollera att förnamn är ifyllt
      while (firstName == null || firstName.isEmpty) {
        stdout.write('Ange förnamn: ');
        firstName = stdin.readLineSync();
        if (firstName == null || firstName.isEmpty) {
          print('Förnamn kan inte vara tomt.');
        }
      }

      // Kontrollera att efternamn är ifyllt
      while (lastName == null || lastName.isEmpty) {
        stdout.write('Ange efternamn: ');
        lastName = stdin.readLineSync();
        if (lastName == null || lastName.isEmpty) {
          print('Efternamn kan inte vara tomt.');
        }
      }

      // Kontrollera att personnummer är ifyllt
      while (personNumber == null || personNumber.isEmpty) {
        stdout.write('Ange personnummer: ');
        personNumber = stdin.readLineSync();
        if (personNumber == null || personNumber.isEmpty) {
          print('Personnummer kan inte vara tomt.');
        }
      }

      // Skapar ett nytt Person-objekt och försöker skapa en person i databasen
      Person? newPerson = await personRepo.create(
        Person(
          firstName: firstName,
          lastName: lastName,
          personNumber: personNumber,
        ),
      );

      // Hantera resultatet av skapandet
      if (newPerson != null) {
        print('Person tillagd!');
      }
      break;

    case '2':
      // Visa alla personer
      print('Alla personer:');
      List<Person> people = await personRepo.getAll();
      for (var person in people) {
        print(
            'Namn: ${person.firstName} ${person.lastName}, Personnummer: ${person.personNumber}');
      }
      break;

    case '3':
      // Uppdatera person
      stdout.write('Ange personnummer för personen som ska uppdateras: ');
      String? personNum = stdin.readLineSync();

      if (personNum == null || personNum.isEmpty) {
        print('Ogiltigt personnummer. Försök igen.');
        break;
      }

      // Hämta personen från databasen
      Person? personToUpdate = await personRepo.getByPersonNumber(personNum);
      if (personToUpdate == null) {
        print('Ingen person hittades med det angivna personnumret.');
        break;
      }

      // Meny för att välja vad som ska uppdateras
      print('Vad vill du uppdatera?');
      print('1. Uppdatera personuppgifter');
      print('2. Uppdatera fordon');

      String? updateChoice = stdin.readLineSync();
      switch (updateChoice) {
        case '1':
          // Uppdatera personuppgifter
          updatePersonDetails(personRepo, personToUpdate);
          break;

        case '2':
          // Uppdatera fordon kopplade till personen
          await updateVehicleDetails(vehicleRepo, personNum);
          break;

        default:
          print('Ogiltigt alternativ. Försök igen.');
          break;
      }

    case '4':
      // Ta bort person
      stdout.write('Ange personnummer för personen som ska tas bort: ');
      String? deleteNumString = stdin.readLineSync();

      if (deleteNumString == null || deleteNumString.isEmpty) {
        print('Ogiltigt personnummer. Försök igen.');
        break;
      }

      // Ta bort fordon kopplade till ägaren först
      await vehicleRepo.deleteByOwner(deleteNumString);

      bool isDeleted = await personRepo.deleteByPersonNumber(deleteNumString);
      if (isDeleted) {
        print('Person borttagen!');
      } else {
        print('Ingen person hittades med det angivna personnumret.');
      }
      break;

    case '5':
      // Visa fordon kopplade till en ägare
      stdout.write('Ange personnummer på fordonets/fordonens ägare: ');
      String? personNum = stdin.readLineSync();

      if (personNum == null || personNum.isEmpty) {
        print('Ogiltigt personnummer. Försök igen.');
        break;
      }

      // Hämta fordon kopplade till ägaren
      List<Vehicle> vehicles =
          await vehicleRepo.getByOwner(personNum: personNum);

      // Hämta ägarens information
      Person? owner = await personRepo.getByPersonNumber(personNum);

      if (vehicles.isEmpty) {
        print('Inga fordon registrerade för denna person.');
      } else {
        String ownerName = owner != null
            ? '${owner.firstName} ${owner.lastName}'
            : 'Okänd ägare';
        print(
            'Fordon registrerade för ägaren $ownerName med personnummer $personNum:');
        for (var vehicle in vehicles) {
          print(' - ${vehicle.toString()}');
        }
      }
      break;

    default:
      print('Ogiltigt alternativ.');
  }
}

Future<void> updatePersonDetails(
    PersonRepository personRepo, Person personToUpdate) async {
  stdout.write('Ange nytt förnamn (${personToUpdate.firstName}): ');
  String? newFirstName = stdin.readLineSync();
  stdout.write('Ange nytt efternamn (${personToUpdate.lastName}): ');
  String? newLastName = stdin.readLineSync();

  // Uppdatera förnamn och efternamn om de anges
  if (newFirstName != null && newFirstName.isNotEmpty) {
    personToUpdate.firstName = newFirstName;
  }
  if (newLastName != null && newLastName.isNotEmpty) {
    personToUpdate.lastName = newLastName;
  }

  // Anropa update med både ID och den uppdaterade personen
  Person? updatedPerson =
      await personRepo.update(personToUpdate.id, personToUpdate);

  if (updatedPerson != null) {
    print('Personuppgifter uppdaterade!');
  } else {
    print('Ingen person hittades med det angivna ID:t.');
  }
}

Future<void> updateVehicleDetails(
    VehicleRepository vehicleRepo, String personId) async {
  // Hämta fordon kopplade till personens personnummer
  final vehicles = await vehicleRepo.getByOwner(personNum: personId);

  if (vehicles.isEmpty) {
    print('Inga fordon hittades för denna person.');
    return;
  }

  // Visa lista över fordon kopplade till personen
  print('Följande fordon tillhör personen:');
  for (var vehicle in vehicles) {
    print(
        'ID: ${vehicle.id}, Modell: ${vehicle.model}, Registreringsnummer: ${vehicle.registrationNumber}, Färg: ${vehicle.color}');
  }

  // Be användaren välja ett fordon att uppdatera
  stdout.write('Ange ID för fordonet du vill uppdatera: ');
  String? vehicleIdStr = stdin.readLineSync();
  int? vehicleId = int.tryParse(vehicleIdStr ?? '');

  if (vehicleId == null) {
    print('Ogiltigt fordon-ID.');
    return;
  }

  // Hämta fordonet från databasen
  final vehicle = await vehicleRepo.getById(vehicleId);
  if (vehicle == null) {
    print('Fordon med det ID:t hittades inte.');
    return;
  }

  // Meny för att uppdatera fordonets attribut
  print('Vad vill du uppdatera i fordonet?');
  print('1. Färg');
  stdout.write('Välj ett alternativ: ');
  String? vehicleUpdateChoice = stdin.readLineSync();

  switch (vehicleUpdateChoice) {
    case '1':
      // Uppdatera färg med möjlighet att behålla den nuvarande färgen
      stdout.write(
          'Ange ny färg för fordonet (tryck Enter för att behålla nuvarande: ${vehicle.color}): ');
      String? newColor = stdin.readLineSync();
      if (newColor == null || newColor.isEmpty) {
        newColor = vehicle.color; // Behåll nuvarande färg
        print('Fordonets färg behålls som $newColor.');
      } else {
        vehicle.color = newColor;
        print('Fordonets färg har uppdaterats till $newColor.');
      }
      await vehicleRepo.update(vehicle.id, vehicle);
      break;

    default:
      print('Ogiltigt alternativ. Försök igen.');
      break;
  }
}

// Hjälpmetod för att hantera val av fordon
Future<int?> getVehicleChoice(int maxChoice) async {
  stdout.write('Välj vilket fordon du vill uppdatera (ange siffra): ');
  String? choice = stdin.readLineSync();
  int? vehicleIndex = int.tryParse(choice ?? '');

  if (vehicleIndex == null || vehicleIndex < 1 || vehicleIndex > maxChoice) {
    return null; // Ogiltigt val
  }

  return vehicleIndex;
}

Future<void> updateVehiclesForOwner(
    VehicleRepository vehicleRepo, Person owner) async {
  print('Fordon kopplade till ${owner.firstName} ${owner.lastName}:');

  // Hämta alla fordon kopplade till ägaren, baserat på personnummer
  List<Vehicle> vehicles = await vehicleRepo.getAll();

  // Filtrera fordon baserat på ägarens personnummer
  vehicles =
      vehicles.where((v) => v.ownerPersonNumber == owner.personNumber).toList();

  if (vehicles.isEmpty) {
    print('Inga fordon kopplade till denna ägare.');
    return;
  }

  // Visa alla fordon som är kopplade till ägaren
  for (int i = 0; i < vehicles.length; i++) {
    print(
        '${i + 1}. Registreringsnummer: ${vehicles[i].registrationNumber}, Typ: ${vehicles[i].model}');
  }

  stdout.write('Välj ett fordon att uppdatera (ange nummer): ');
  int? vehicleChoice = int.tryParse(stdin.readLineSync()!);

  if (vehicleChoice == null ||
      vehicleChoice < 1 ||
      vehicleChoice > vehicles.length) {
    print('Ogiltigt val.');
    return;
  }

  // Hämta valt fordon baserat på användarens val
  Vehicle selectedVehicle = vehicles[vehicleChoice - 1];

  stdout.write(
      'Ange ny typ av fordon (Bil, Motorcykel, Lastbil, Husbil, Buss, Moped, Traktor): ');
  String? newType = stdin.readLineSync();

  // Uppdatera fordonets typ om en ny typ anges
  if (newType != null && newType.isNotEmpty) {
    selectedVehicle.model = newType;

    // Uppdatera fordonet i databasen
    await vehicleRepo.update(selectedVehicle.id, selectedVehicle);
    print('Fordon uppdaterat!');
  } else {
    print('Ingen ändring gjordes.');
  }
}

Future<void> handleVehicles(
    VehicleRepository vehicleRepo, PersonRepository personRepo) async {
  stdout.write(
      'Vad vill du göra med fordon? (1: Skapa, 2: Visa, 3: Uppdatera, 4: Ta bort): ');
  String? action = stdin.readLineSync();

  List<String> vehicleTypes = [
    'Bil',
    'Motorcykel',
    'Lastbil',
    'Husbil',
    'Buss',
    'Moped',
    'Traktor'
  ];

  switch (action) {
    case '1':
      // Skapa nytt fordon
      stdout.write('Ange registreringsnummer: ');
      String? regNum = stdin.readLineSync();
      if (regNum == null || regNum.isEmpty) {
        print('Registreringsnummer krävs.');
        break;
      }

      // Kontrollera om ett fordon med samma registreringsnummer redan finns
      final existingVehicle =
          await vehicleRepo.getByRegistreringsnummer(regNum);
      if (existingVehicle != null) {
        print('Ett fordon med detta registreringsnummer finns redan.');
        break;
      }

      print('Välj typ av fordon genom att ange en siffra:');
      for (int i = 0; i < vehicleTypes.length; i++) {
        print('${i + 1}. ${vehicleTypes[i]}');
      }

      int? typeChoice = int.tryParse(stdin.readLineSync()!);
      if (typeChoice == null ||
          typeChoice < 1 ||
          typeChoice > vehicleTypes.length) {
        print('Ogiltigt val av fordonstyp, försök igen.');
        break;
      }

      String selectedType = vehicleTypes[typeChoice - 1];

      stdout.write('Ange färg för fordonet: ');
      String? color = stdin.readLineSync();
      if (color == null || color.isEmpty) {
        color = 'Standardfärg';
      }

      stdout.write('Ange årsmodell för fordonet: ');
      String? inputYear = stdin.readLineSync();
      if (inputYear == null || inputYear.isEmpty) {
        print('Årsmodell krävs.');
        break;
      }

      int? year = int.tryParse(inputYear);
      if (year == null) {
        print('Ogiltigt årtal. Vänligen ange ett korrekt årtal.');
        break;
      }
      stdout.write('Ange ägarens personnummer: ');
      String? ownerNum = stdin.readLineSync();
      if (ownerNum == null || ownerNum.isEmpty) {
        print('Personnummer krävs.');
        break;
      }

      Person? owner = await personRepo.getByPersonNumber(ownerNum);
      if (owner == null) {
        print('Ingen ägare hittades med detta personnummer.');
        break;
      }

      // Skapa och spara fordonet
      await vehicleRepo.create(Vehicle(
        registrationNumber: regNum,
        model: selectedType,
        ownerId: owner.id,
        ownerPersonNumber: owner.personNumber!,
        color: color,
        year: year,
      ));

      // Logga efter att fordonet har sparats
      print(
          'Fordon tillagt! Registreringsnummer: $regNum, Typ: $selectedType, Färg: $color, Årsmodell: $year');
      break;

    case '2':
      // Hämta alla fordon asynkront
      List<Vehicle> vehicles = await vehicleRepo.getAll();

      if (vehicles.isEmpty) {
        print('Inga fordon registrerade.');
      } else {
        print('Alla fordon:');
        for (var vehicle in vehicles) {
          print(
              'Registreringsnummer: ${vehicle.registrationNumber}, Typ: ${vehicle.model}, Färg: ${vehicle.color}, Årsmodell: ${vehicle.year}, Ägare: ${vehicle.ownerPersonNumber}');
        }
      }
      break;

    case '3':
      // Uppdatera fordon
      stdout
          .write('Ange registreringsnummer för fordonet som ska uppdateras: ');
      String? updateRegNum = stdin.readLineSync();

      // Hämta fordonet baserat på registreringsnumret
      Vehicle? existingVehicle =
          await vehicleRepo.getByRegistreringsnummer(updateRegNum!);

      if (existingVehicle == null) {
        print('Inget fordon med registreringsnumret hittades.');
        return;
      }

      // Visa nuvarande färg inom parentes
      print('Nuvarande färg: (${existingVehicle.color})');
      stdout.write(
          'Ange ny färg för fordonet (tryck Enter för att behålla den gamla färgen): ');

      String? newColor = stdin.readLineSync();

      // Om användaren inte skriver något, behåll den gamla färgen
      if (newColor == null || newColor.isEmpty) {
        newColor = existingVehicle.color; // Behåll den gamla färgen
      }

      // Uppdatera fordonets färg
      existingVehicle.color = newColor;

      // Uppdatera fordonet med den nya färgen
      await vehicleRepo.update(existingVehicle.id, existingVehicle);
      print('Fordonets färg uppdaterad till: $newColor');
      break;

    case '4':
      // Ta bort fordon
      stdout.write('Ange registreringsnummer för fordonet som ska tas bort: ');
      String? deleteRegNum = stdin.readLineSync();

      if (deleteRegNum != null && deleteRegNum.isNotEmpty) {
        bool success =
            await vehicleRepo.deleteByRegistreringsnummer(deleteRegNum);

        if (success) {
          print('Fordon borttaget!');
        } else {
          print(
              'Fordonet med registreringsnummer $deleteRegNum kunde inte tas bort.');
        }
      } else {
        print('Ogiltigt registreringsnummer.');
      }
      break;
  }
}

Future<void> handleParkingSpaces(
    ParkingSpaceRepository parkingSpaceRepo) async {
  stdout.write(
      'Vad vill du göra med parkeringsplatser? (1: Skapa, 2: Visa, 3: Uppdatera, 4: Ta bort): ');
  String? action = stdin.readLineSync();

  switch (action) {
    case '1':
      // Skapa ny parkeringsplats
      stdout.write('Ange ID för parkeringsplats: ');
      int? id = int.tryParse(stdin.readLineSync()!);

      // Kontrollera om ID redan finns
      if (id == null) {
        print('Ogiltigt ID, vänligen ange ett nummer.');
        return;
      }

      if (parkingSpaceRepo.idExists(id)) {
        print(
            'En parkeringsplats med ID $id finns redan. Vänligen ange ett annat ID.');
        return;
      }

      stdout.write('Ange adress för parkeringsplats: ');
      String? adress = stdin.readLineSync();
      stdout.write('Ange pris per timme (SEK): ');
      double? price = double.tryParse(stdin.readLineSync()!);

      if (adress != null && price != null) {
        await parkingSpaceRepo
            .create(ParkingSpace(id: id, address: adress, pricePerHour: price));
        print('Parkeringsplats tillagd!');
      } else {
        print('Vänligen kontrollera att alla uppgifter är angivna korrekt.');
      }
      break;

    case '2':
      // Visa alla parkeringsplatser
      print('Alla parkeringsplatser:');
      List<ParkingSpace> spaces = await parkingSpaceRepo.getAll();
      for (var space in spaces) {
        print(
            'ID: ${space.id}, Adress: ${space.address}, Pris per timme: ${space.pricePerHour}');
      }
      break;

    case '3':
      // Uppdatera parkeringsplats
      stdout.write('Ange ID för parkeringsplatsen som ska uppdateras: ');
      int? updateId = int.tryParse(stdin.readLineSync()!);

      ParkingSpace? existingSpace = await parkingSpaceRepo.getById(updateId!);

      if (existingSpace != null) {
        print('Nuvarande adress: ${existingSpace.address}');
        stdout.write(
            'Ange ny adress (tryck Enter för att behålla den nuvarande): ');
        String? newAddress = stdin.readLineSync();

        print('Nuvarande pris per timme: ${existingSpace.pricePerHour}');
        stdout.write(
            'Ange nytt pris per timme (tryck Enter för att behålla det nuvarande): ');
        String? newPriceInput = stdin.readLineSync();

        // Behåll det gamla värdet om användaren trycker Enter
        if (newAddress != null && newAddress.isNotEmpty) {
          existingSpace.address = newAddress;
        }

        if (newPriceInput != null && newPriceInput.isNotEmpty) {
          double? newPrice = double.tryParse(newPriceInput);
          if (newPrice != null) {
            existingSpace.pricePerHour = newPrice;
          } else {
            print('Ogiltigt pris angivet. Behåller det gamla priset.');
          }
        }

        await parkingSpaceRepo.update(existingSpace.id, existingSpace);
        print('Parkeringsplats uppdaterad!');
      } else {
        print('Ingen parkeringsplats hittades med det angivna ID:t.');
      }
      break;

    case '4':
      // Ta bort parkeringsplats
      stdout.write('Ange ID för parkeringsplatsen som ska tas bort: ');
      int? deleteId = int.tryParse(stdin.readLineSync()!);

      if (deleteId != null) {
        parkingSpaceRepo.delete(deleteId);
        print('Parkeringsplats borttagen!');
      } else {
        print('Ogiltigt ID.');
      }
      break;

    default:
      print('Ogiltigt alternativ.');
  }
}

Future<void> handleParkings(
  ParkingRepository parkingRepo,
  VehicleRepository vehicleRepo,
  ParkingSpaceRepository parkingSpaceRepo,
) async {
  stdout.write(
      'Vad vill du göra med parkeringar? (1: Starta ny parkering, 2: Visa alla, 3: Avsluta parkering, 4: Ta bort parkering permanent från systemet): ');
  String? action = stdin.readLineSync();

  switch (action) {
    case '1':
      // Starta ny parkering
      stdout.write('Ange registreringsnummer för fordonet: ');
      String? regNum = stdin.readLineSync();
      if (regNum == null || regNum.isEmpty) {
        print('Registreringsnummer krävs.');
        break;
      }

      Vehicle? vehicle = await vehicleRepo.getByRegistreringsnummer(regNum);
      if (vehicle == null) {
        print('Inget fordon hittades med det angivna registreringsnumret.');
        break;
      }

      stdout.write('Ange ID för parkeringsplatsen: ');
      String? spaceIdInput = stdin.readLineSync();
      if (spaceIdInput == null || spaceIdInput.isEmpty) {
        print('Parkeringsplats-ID krävs.');
        break;
      }

      int? spaceId = int.tryParse(spaceIdInput);
      if (spaceId == null) {
        print('Ogiltigt parkeringsplats-ID.');
        break;
      }

      ParkingSpace? space = await parkingSpaceRepo.getById(spaceId);
      if (space == null) {
        print('Ingen parkeringsplats hittades med det angivna ID:t.');
        break;
      }

      // Kontrollera om det redan finns en pågående parkering för detta fordon och denna parkeringsplats
      Parking? ongoingParking =
          await parkingRepo.getOngoingParking(vehicle.id, spaceId);
      if (ongoingParking != null) {
        print(
            'Det finns redan en pågående parkering för detta fordon på denna plats.');
        break;
      }

      // Hämta nästa lediga ID för parkeringen
      int nextId = await parkingRepo.getNextAvailableId();

      // Skapa ett nytt parkeringsobjekt
      Parking parking = Parking(
        id: nextId,
        vehicleId: vehicle.id,
        parkingSpaceId: space.id,
        startTime: DateTime.now(),
      );

      await parkingRepo.create(parking);

      // ask server to create the parking

      print(
          'Parkering startad för fordon ${vehicle.registrationNumber} på plats ${space.address}.');
      break;

    case '2':
      // Hämta alla parkeringar med detaljer
      List<Map<String, dynamic>> parkingsWithDetails =
          await parkingRepo.getAllWithDetails();

      // Separera pågående och avslutade parkeringar
      var ongoingParkings = parkingsWithDetails.where((details) {
        final parking = details['parking'] as Parking;
        return parking.endTime == null; // Pågående parkeringar
      }).toList();

      var finishedParkings = parkingsWithDetails.where((details) {
        final parking = details['parking'] as Parking;
        return parking.endTime != null; // Avslutade parkeringar
      }).toList();

      // Visa pågående parkeringar
      if (ongoingParkings.isNotEmpty) {
        print('Pågående parkeringar:');
        for (var details in ongoingParkings) {
          final parking = details['parking'] as Parking;
          final vehicleInfo = details['vehicle'];
          final parkingSpaceInfo = details['parkingSpace'];

          String formattedStart =
              '${parking.startTime.hour}:${parking.startTime.minute.toString().padLeft(2, '0')}';

          print(
              'ID: ${parking.id}, Fordon: $vehicleInfo, Parkeringsplats: $parkingSpaceInfo, Starttid: $formattedStart, Sluttid: Pågående');
        }
      }

      // Visa avslutade parkeringar
      if (finishedParkings.isNotEmpty) {
        print('\nAvslutade parkeringar:');
        for (var details in finishedParkings) {
          final parking = details['parking'] as Parking;
          final vehicleInfo = details['vehicle'];
          final parkingSpaceInfo = details['parkingSpace'];

          String formattedStart =
              '${parking.startTime.hour}:${parking.startTime.minute.toString().padLeft(2, '0')}';
          String formattedEnd =
              '${parking.endTime!.hour}:${parking.endTime!.minute.toString().padLeft(2, '0')}';

          // Beräkna total tid och kostnad
          final int totalMinutes =
              parking.endTime!.difference(parking.startTime).inMinutes;
          double hoursParked = totalMinutes / 60.0;

          ParkingSpace? parkingSpace =
              await parkingSpaceRepo.getById(parking.parkingSpaceId);

          double totalCost = parkingSpace != null
              ? (hoursParked * parkingSpace.pricePerHour).ceilToDouble()
              : 0.0;

          print(
              'ID: ${parking.id}, Fordon: $vehicleInfo, Parkeringsplats: $parkingSpaceInfo, Starttid: $formattedStart, Sluttid: $formattedEnd, Kostnad: ${totalCost.toStringAsFixed(2)} kr');
        }
      } else {
        print('\nInga avslutade parkeringar hittades.');
      }

      if (ongoingParkings.isEmpty && finishedParkings.isEmpty) {
        print('Inga parkeringar hittades.');
      }

      break;

    case '3':
      // Avsluta parkering
      stdout.write('Ange ID för parkeringen som ska avslutas: ');
      String? endParkingIdInput = stdin.readLineSync();
      if (endParkingIdInput == null || endParkingIdInput.isEmpty) {
        print('Parkering-ID krävs.');
        break;
      }

      int? endParkingId = int.tryParse(endParkingIdInput);
      if (endParkingId == null) {
        print('Ogiltigt parkering-ID.');
        break;
      }

      // Hämta den aktuella parkeringen från databasen
      Parking? parkingToEnd = await parkingRepo.getById(endParkingId);
      if (parkingToEnd == null) {
        print('Ingen parkering hittades med det angivna ID:t.');
        break;
      }

      // Kontrollera om parkeringen redan är avslutad
      if (parkingToEnd.endTime != null) {
        print('Denna parkering är redan avslutad.');
        break;
      }

      // Sätt sluttid för parkeringen
      parkingToEnd.endTime = DateTime.now();

      // Uppdatera parkeringen i databasen med sluttiden
      await parkingRepo.update(parkingToEnd.id, parkingToEnd);

      // Hämta parkeringsplatsens pris per timme
      ParkingSpace? parkingSpace =
          await parkingSpaceRepo.getById(parkingToEnd.parkingSpaceId);
      if (parkingSpace == null) {
        print('Kunde inte hämta information om parkeringsplatsen.');
        break;
      }

      // Formaterar start- och sluttid
      String formattedStartTime =
          "${parkingToEnd.startTime.hour}:${parkingToEnd.startTime.minute.toString().padLeft(2, '0')}";
      String formattedEndTime =
          "${parkingToEnd.endTime!.hour}:${parkingToEnd.endTime!.minute.toString().padLeft(2, '0')}";

      // Beräknar total parkeringstid i minuter
      final int totalMinutes =
          parkingToEnd.endTime!.difference(parkingToEnd.startTime).inMinutes;

      // Konverterar total parkeringstid till hela timmar och minuter
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      // Beräknar kostnad
      double hoursParked = totalMinutes / 60.0;
      double totalCost =
          (hoursParked * parkingSpace.pricePerHour).ceilToDouble();

      // Visa bekräftelsemeddelande
      print('Parkeringen med ID ${parkingToEnd.id} har avslutats.');
      print('Starttid: $formattedStartTime');
      print('Sluttid: $formattedEndTime');
      print('Total tid: $hours timmar och $minutes minuter.');
      print('Kostnad för parkeringen: $totalCost kr.');
      break;

    case '4':
      // Ta bort parkering
      stdout.write('Ange ID för parkeringen som ska tas bort: ');
      String? deleteIdInput = stdin.readLineSync();
      if (deleteIdInput == null || deleteIdInput.isEmpty) {
        print('Parkering-ID krävs.');
        break;
      }

      int? deleteId = int.tryParse(deleteIdInput);
      if (deleteId == null) {
        print('Ogiltigt parkering-ID.');
        break;
      }

      // Hämta parkeringen för att kontrollera dess status
      Parking? parkingToDelete = await parkingRepo.getById(deleteId);
      if (parkingToDelete == null) {
        print('Ingen parkering hittades med det angivna ID:t.');
        break;
      }

      if (parkingToDelete.endTime == null) {
        print(
            'Det går inte att radera en pågående parkering. Avsluta parkeringen först.');
        break;
      }

      // Om parkeringen är avslutad, radera den
      await parkingRepo.delete(deleteId);
      print('Parkeringen med ID $deleteId har tagits bort permanent.');
      break;

    default:
      print('Ogiltigt alternativ.');
  }
}
