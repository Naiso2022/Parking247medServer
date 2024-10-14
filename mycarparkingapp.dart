import 'dart:io';

class Person {
  String firstName;
  String lastName;
  String personNumber;
  String get namn => '$firstName $lastName';

  Person(
      {required this.personNumber,
      required this.firstName,
      required this.lastName});
}

class Vehicle {
  String registreringsnummer;
  String typ; // Bil, motorcykel, etc.
  Person owner;

  Vehicle({
    required this.registreringsnummer,
    required this.typ,
    required this.owner,
  });

  @override
  String toString() {
    return 'Registreringsnummer: $registreringsnummer, Fordonstyp: $typ';
  }
}

class ParkingSpace {
  int id;
  String adress;
  double pricePerHour;

  ParkingSpace({
    required this.id,
    required this.adress,
    required this.pricePerHour,
  });

  @override
  String toString() {
    return 'ID: $id, Adress: $adress';
  }
}

class Parking {
  static int _idCounter = 0; // Static counter för att generera unika ID
  int id;
  Vehicle fordon;
  ParkingSpace parkeringsplats;
  DateTime starttid;
  DateTime? sluttid; // Kan vara null om pågående

  Parking({
    required this.fordon,
    required this.parkeringsplats,
    required this.starttid,
    this.sluttid,
  }) : id = _idCounter++; // Tilldela unikt ID vid skapandet

  @override
  String toString() {
    // Formatera timmar och minuter med padLeft(2, '0')
    String formattedStart =
        '${starttid.hour.toString().padLeft(2, '0')}:${starttid.minute.toString().padLeft(2, '0')}';
    String formattedEnd = sluttid != null
        ? '${sluttid!.hour.toString().padLeft(2, '0')}:${sluttid!.minute.toString().padLeft(2, '0')}'
        : 'Pågående';

    return 'ID: $id, Fordon: ${fordon.registreringsnummer}, Parkeringsplats: ${parkeringsplats.adress}, Starttid: $formattedStart, Sluttid: $formattedEnd';
  }
}


class PersonRepository {
  final List<Person> _persons = [];

  void add(Person person) {
    _persons.add(person);
  }

  List<Person> getAll() {
    return _persons;
  }

  Person? getBypersonnumber(String personNumber) {
    try {
      return _persons
          .firstWhere((person) => person.personNumber == personNumber);
    } catch (e) {
      return null; // Returnera null om ingen person hittas
    }
  }

  void update(Person updatedPerson) {
    int index = _persons
        .indexWhere((p) => p.personNumber == updatedPerson.personNumber);
    if (index != -1) {
      _persons[index] = updatedPerson;
    }
  }

  void delete(String personNumber) {
    _persons.removeWhere((person) => person.personNumber == personNumber);
  }
}

class VehicleRepository {
  final List<Vehicle> _vehicles = [];

  void add(Vehicle vehicle) {
    _vehicles.add(vehicle);
  }

  List<Vehicle> getAll() {
    return _vehicles;
  }

  Vehicle? getByRegistreringsnummer(String registreringsnummer) {
    try {
      return _vehicles.firstWhere(
          (vehicle) => vehicle.registreringsnummer == registreringsnummer);
    } catch (e) {
      return null; // Returnera null om inget fordon hittas
    }
  }

  void update(Vehicle updatedVehicle) {
    int index = _vehicles.indexWhere(
        (v) => v.registreringsnummer == updatedVehicle.registreringsnummer);
    if (index != -1) {
      _vehicles[index] = updatedVehicle;
    }
  }

  void delete(String registreringsnummer) {
    _vehicles.removeWhere(
        (vehicle) => vehicle.registreringsnummer == registreringsnummer);
  }

  // Metod för att ta bort alla fordon för en viss ägare
  void deleteByOwner(String ownerPersonNumber) {
    _vehicles.removeWhere(
        (vehicle) => vehicle.owner.personNumber == ownerPersonNumber);
  }

  // **Ny metod för att hämta alla fordon för en viss ägare**
  List<Vehicle> getByOwner(String ownerPersonNumber) {
    return _vehicles
        .where((vehicle) => vehicle.owner.personNumber == ownerPersonNumber)
        .toList();
  }
}

class ParkingSpaceRepository {
  final List<ParkingSpace> _parkingSpaces = [];

  void add(ParkingSpace parkingSpace) {
    _parkingSpaces.add(parkingSpace);
  }

  List<ParkingSpace> getAll() {
    return _parkingSpaces;
  }

  ParkingSpace? getById(int id) {
    try {
      return _parkingSpaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null; // Returnera null om ingen parkeringsplats hittas
    }
  }

  bool idExists(int id) {
    // Returnera true om det finns en parkeringsplats med samma ID
    return _parkingSpaces.any((space) => space.id == id);
  }

  void update(ParkingSpace updatedParkingSpace) {
    int index =
        _parkingSpaces.indexWhere((p) => p.id == updatedParkingSpace.id);
    if (index != -1) {
      _parkingSpaces[index] = updatedParkingSpace;
    }
  }

  void delete(int id) {
    _parkingSpaces.removeWhere((parkingSpace) => parkingSpace.id == id);
  }
}

class ParkingRepository {
  final List<Parking> _parkings = [];

  void add(Parking parking) {
    _parkings.add(parking);
    print('Parkering tillagd med ID: ${parking.id}');
  }

  List<Parking> getAll() {
    return _parkings;
  }

  Parking? getById(int id) {
    try {
      return _parkings.firstWhere((parking) => parking.id == id);
    } catch (e) {
      return null; // Returnera null om ingen parkering hittas
    }
  }

  void update(int id, Parking updatedParking) {
    int index = _parkings.indexWhere((p) => p.id == id);
    if (index != -1) {
      _parkings[index] = updatedParking;
      print('Parkering med ID $id har uppdaterats.');
    } else {
      print('Ingen parkering hittades med ID $id.');
    }
  }

  void delete(int id) {
    // Hitta indexet för parkeringen med det angivna ID:t
    int index = _parkings.indexWhere((parking) => parking.id == id);

    if (index != -1) {
      _parkings.removeAt(index);
      print('Parkering med ID $id har tagits bort.');
    } else {
      print('Ingen parkering hittades med ID $id.');
    }
  }
}

void main() {
  var personRepo = PersonRepository();
  var vehicleRepo = VehicleRepository();
  var parkingSpaceRepo = ParkingSpaceRepository();
  var parkingRepo = ParkingRepository();

  cliFlow(personRepo, vehicleRepo, parkingSpaceRepo, parkingRepo);
}

void cliFlow(PersonRepository personRepo, VehicleRepository vehicleRepo,
    ParkingSpaceRepository parkingSpaceRepo, ParkingRepository parkingRepo) {
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
    if (choice == '5') break; // Avsluta programmet

    switch (choice) {
      case '1':
        handlePersons(personRepo, vehicleRepo);
        break;
      case '2':
        handleVehicles(vehicleRepo, personRepo);
        break;
      case '3':
        handleParkingSpaces(parkingSpaceRepo);
        break;
      case '4':
        handleParkings(parkingRepo, vehicleRepo, parkingSpaceRepo);
        break;
      default:
        print('Ogiltigt val, försök igen.');
        break;
    }
  }
}

void handlePersons(PersonRepository personRepo, VehicleRepository vehicleRepo) {
  stdout.write(
      'Vad vill du göra med personer? (1: Skapa, 2: Visa, 3: Uppdatera, 4: Ta bort, 5: Visa persons fordon): ');
  String? action = stdin.readLineSync();

  switch (action) {
    case '1':
      // Skapa ny person
      stdout.write('Ange förnamn: ');
      String? firstName = stdin.readLineSync();
      stdout.write('Ange efternamn: ');
      String? lastName = stdin.readLineSync();
      stdout.write('Ange personnummer: ');
      String? personNumber = stdin.readLineSync();

      if (firstName != null && lastName != null && personNumber != null) {
        personRepo.add(
          Person(
            firstName: firstName,
            lastName: lastName,
            personNumber: personNumber,
          ),
        );
        print('Person tillagd!');
      } else {
        print('Vänligen fyll i alla fält.');
      }
      break;

    case '2':
      // Visa alla personer
      print('Alla personer:');
      for (var person in personRepo.getAll()) {
        print(
            'Namn: ${person.firstName} ${person.lastName}, Personnummer: ${person.personNumber}');
      }
      break;

    case '3':
      // Uppdatera person
      stdout.write('Ange personnummer för personen som ska uppdateras: ');
      String? personNum = stdin.readLineSync();

      // Kontrollera att personNum inte är null eller tom
      if (personNum == null || personNum.isEmpty) {
        print('Ogiltigt personnummer. Försök igen.');
        break; // Avsluta switchen om användaren inte angav ett giltigt nummer
      }

      // Hämta personen från databasen
      Person? personToUpdate = personRepo.getBypersonnumber(personNum);
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
          // Anropa en metod för att uppdatera personuppgifter
          updatePersonDetails(personRepo, personToUpdate);
          break;
        case '2':
          // Anropa en metod för att uppdatera fordon
          updateVehicleDetails(vehicleRepo, personNum);
          break;
        default:
          print('Ogiltigt alternativ. Försök igen.');
          break;
      }
      break;

    case '4':
      // Ta bort person
      stdout.write('Ange personnummer för personen som ska tas bort: ');
      String? deleteNum = stdin.readLineSync();

      // Kontrollera att deleteNum inte är null eller tom
      if (deleteNum == null || deleteNum.isEmpty) {
        print('Ogiltigt personnummer. Försök igen.');
        break; // Avsluta switchen om användaren inte angav ett giltigt nummer
      }

      // Ta bort fordon kopplade till ägaren först
      vehicleRepo.deleteByOwner(deleteNum);

      // Ta bort personen
      personRepo.delete(deleteNum);
      print('Person borttagen!');
      break;

    case '5':
      // Visa fordon kopplade till en ägare
      stdout.write('Ange personnummer på fordonets/fordonens ägare: ');
      String? personNum = stdin.readLineSync();

      // Kontrollera att personNum inte är null eller tom
      if (personNum == null || personNum.isEmpty) {
        print('Ogiltigt personnummer. Försök igen.');
        break; // Avsluta switchen om användaren inte angav ett giltigt nummer
      }

      // Hämta fordon kopplade till ägaren
      List<Vehicle> vehicles = vehicleRepo.getByOwner(
          personNum); // Anta att det finns en metod som returnerar fordon kopplade till ägaren

      // Hämta ägarens information
      Person? owner = personRepo.getBypersonnumber(
          personNum); // Hämta personen med det angivna personnumret

      if (vehicles.isEmpty) {
        print('Inga fordon registrerade för denna person.');
      } else {
        String ownerName = owner != null
            ? '${owner.firstName} ${owner.lastName}'
            : 'Okänd ägare'; // Hämta ägarens namn
        print(
            'Fordon registrerade för ägaren $ownerName med personnummer $personNum:');
        for (var vehicle in vehicles) {
          print(' - ${vehicle.toString()}'); // Använder toString-metoden
        }
      }
      break;

    default:
      print('Ogiltigt alternativ.');
  }
}

void updatePersonDetails(PersonRepository personRepo, Person person) {
  stdout.write('Ange nya förnamn (nuvarande: ${person.firstName}): ');
  String? newFirstName = stdin.readLineSync();
  if (newFirstName != null && newFirstName.isNotEmpty) {
    person.firstName = newFirstName;
  }

  stdout.write('Ange nya efternamn (nuvarande: ${person.lastName}): ');
  String? newLastName = stdin.readLineSync();
  if (newLastName != null && newLastName.isNotEmpty) {
    person.lastName = newLastName;
  }

  // Spara uppdaterade personuppgifter i databasen
  personRepo.update(person);

  print('Personuppgifter har uppdaterats!');
}

void updateVehicleDetails(VehicleRepository vehicleRepo, String personNum) {
  List<Vehicle> vehicles = vehicleRepo.getByOwner(personNum);

  if (vehicles.isEmpty) {
    print('Inga fordon kopplade till denna person.');
    return;
  }

  print('Dina fordon:');
  for (int i = 0; i < vehicles.length; i++) {
    print('${i + 1}. ${vehicles[i].registreringsnummer}');
  }

  stdout.write('Välj ett fordon att uppdatera: ');
  String? vehicleChoice = stdin.readLineSync();
  int? vehicleIndex = int.tryParse(vehicleChoice!);

  if (vehicleIndex != null &&
      vehicleIndex > 0 &&
      vehicleIndex <= vehicles.length) {
    Vehicle selectedVehicle = vehicles[vehicleIndex - 1];

    stdout.write(
        'Ange ny registreringsnummer (nuvarande: ${selectedVehicle.registreringsnummer}): ');
    String? newRegNum = stdin.readLineSync();

    if (newRegNum != null && newRegNum.isNotEmpty) {
      selectedVehicle.registreringsnummer = newRegNum;
    }

    // Spara uppdaterat fordon i databasen
    vehicleRepo.update(selectedVehicle);

    print('Fordonet har uppdaterats!');
  } else {
    print('Ogiltigt val.');
  }
}

void updateVehiclesForOwner(VehicleRepository vehicleRepo, Person owner) {
  print('Fordon kopplade till ${owner.namn}:');
  List<Vehicle> vehicles = vehicleRepo
      .getAll()
      .where((v) => v.owner.personNumber == owner.personNumber)
      .toList();

  if (vehicles.isEmpty) {
    print('Inga fordon kopplade till denna ägare.');
    return;
  }

  for (int i = 0; i < vehicles.length; i++) {
    print(
        '${i + 1}. Registreringsnummer: ${vehicles[i].registreringsnummer}, Typ: ${vehicles[i].typ}');
  }

  stdout.write('Välj ett fordon att uppdatera (ange nummer): ');
  int? vehicleChoice = int.tryParse(stdin.readLineSync()!);

  if (vehicleChoice == null ||
      vehicleChoice < 1 ||
      vehicleChoice > vehicles.length) {
    print('Ogiltigt val.');
    return;
  }

  Vehicle selectedVehicle =
      vehicles[vehicleChoice - 1]; // Välj fordonet baserat på användarens val
  stdout.write(
      'Ange ny typ av fordon (Bil, Motorcykel, Lastbil, Husbil, Buss, Moped, Traktor): ');
  String? newType = stdin.readLineSync();

  if (newType != null) {
    selectedVehicle.typ = newType;
    vehicleRepo.update(selectedVehicle);
    print('Fordon uppdaterat!');
  }
}

void handleVehicles(
    VehicleRepository vehicleRepo, PersonRepository personRepo) {
  stdout.write(
      'Vad vill du göra med fordon? (1: Skapa, 2: Visa, 3: Uppdatera, 4: Ta bort): ');
  String? action = stdin.readLineSync();

  // Flytta vehicleTypes utanför switch-satsen så att det är tillgängligt överallt
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

      print('Välj typ av fordon genom att ange en siffra:');
      for (int i = 0; i < vehicleTypes.length; i++) {
        print('${i + 1}. ${vehicleTypes[i]}');
      }

      int? typeChoice = int.tryParse(stdin.readLineSync()!);
      if (typeChoice == null ||
          typeChoice < 1 ||
          typeChoice > vehicleTypes.length) {
        print('Ogiltigt val, försök igen.');
        return;
      }

      String selectedType = vehicleTypes[typeChoice - 1]; // Vald fordonstyp

      stdout.write('Ange ägarens personnummer: ');
      String? ownerNum = stdin.readLineSync();

      Person? owner = personRepo.getBypersonnumber(ownerNum!); // Hämta ägaren

      if (regNum != null && owner != null) {
        vehicleRepo.add(Vehicle(
            registreringsnummer: regNum, typ: selectedType, owner: owner));
        print('Fordon tillagt!');
      } else {
        print('Vänligen kontrollera att alla uppgifter är angivna korrekt.');
      }
      break;

    case '2':
      // Visa alla fordon
      print('Alla fordon:');
      for (var vehicle in vehicleRepo.getAll()) {
        print(
            'Registreringsnummer: ${vehicle.registreringsnummer}, Typ: ${vehicle.typ}, Ägare: ${vehicle.owner.namn}');
      }
      break;

    case '3':
      // Uppdatera fordon
      stdout
          .write('Ange registreringsnummer för fordonet som ska uppdateras: ');
      String? updateRegNum = stdin.readLineSync();
      Vehicle? existingVehicle =
          vehicleRepo.getByRegistreringsnummer(updateRegNum!);
      if (existingVehicle != null) {
        print('Välj ny typ av fordon genom att ange en siffra:');
        for (int i = 0; i < vehicleTypes.length; i++) {
          print('${i + 1}. ${vehicleTypes[i]}');
        }

        int? newTypeChoice = int.tryParse(stdin.readLineSync()!);
        if (newTypeChoice == null ||
            newTypeChoice < 1 ||
            newTypeChoice > vehicleTypes.length) {
          print('Ogiltigt val, försök igen.');
          return;
        }

        String newSelectedType =
            vehicleTypes[newTypeChoice - 1]; // Ny vald fordonstyp

        existingVehicle.typ = newSelectedType;
        vehicleRepo.update(existingVehicle);
        print('Fordon uppdaterat!');
      } else {
        print('Inget fordon hittades med det angivna registreringsnumret.');
      }
      break;

    case '4':
      // Ta bort fordon
      stdout.write('Ange registreringsnummer för fordonet som ska tas bort: ');
      String? deleteRegNum = stdin.readLineSync();
      vehicleRepo.delete(deleteRegNum!);
      print('Fordon borttaget!');
      break;

    default:
      print('Ogiltigt alternativ.');
  }
}

void handleParkingSpaces(ParkingSpaceRepository parkingSpaceRepo) {
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
        parkingSpaceRepo
            .add(ParkingSpace(id: id, adress: adress, pricePerHour: price));
        print('Parkeringsplats tillagd!');
      } else {
        print('Vänligen kontrollera att alla uppgifter är angivna korrekt.');
      }
      break;

    case '2':
      // Visa alla parkeringsplatser
      print('Alla parkeringsplatser:');
      for (var space in parkingSpaceRepo.getAll()) {
        print(
            'ID: ${space.id}, Adress: ${space.adress}, Pris per timme: ${space.pricePerHour}');
      }
      break;

    case '3':
      // Uppdatera parkeringsplats
      stdout.write('Ange ID för parkeringsplatsen som ska uppdateras: ');
      int? updateId = int.tryParse(stdin.readLineSync()!);
      ParkingSpace? existingSpace = parkingSpaceRepo.getById(updateId!);

      if (existingSpace != null) {
        stdout.write('Ange ny adress: ');
        String? newAddress = stdin.readLineSync();
        stdout.write('Ange nytt pris per timme: ');
        double? newPrice = double.tryParse(stdin.readLineSync()!);

        if (newAddress != null && newPrice != null) {
          existingSpace.adress = newAddress;
          existingSpace.pricePerHour = newPrice;
          parkingSpaceRepo.update(existingSpace);
          print('Parkeringsplats uppdaterad!');
        } else {
          print('Vänligen kontrollera att alla uppgifter är angivna korrekt.');
        }
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

void handleParkings(ParkingRepository parkingRepo,
    VehicleRepository vehicleRepo, ParkingSpaceRepository parkingSpaceRepo) {
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

      Vehicle? vehicle = vehicleRepo.getByRegistreringsnummer(regNum);
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

      ParkingSpace? space = parkingSpaceRepo.getById(spaceId);
      if (space == null) {
        print('Ingen parkeringsplats hittades med det angivna ID:t.');
        break;
      }

      // Starta parkering
      Parking parking = Parking(
        fordon: vehicle,
        parkeringsplats: space,
        starttid: DateTime.now(),
      );
      parkingRepo.add(parking);
      print(
          'Parkering startad för fordon ${vehicle.registreringsnummer} på plats ${space.adress}.');
      break;

    case '2':
      // Visa alla parkeringar
      print('Alla parkeringar:');
      for (var parking in parkingRepo.getAll()) {
        String formattedStart =
            '${parking.starttid.hour}:${parking.starttid.minute}';
        String formattedEnd = parking.sluttid != null
            ? '${parking.sluttid!.hour}:${parking.sluttid!.minute}'
            : 'Pågående';
        print(
            'ID: ${parking.id}, Fordon: ${parking.fordon.registreringsnummer}, Parkeringsplats: ${parking.parkeringsplats.adress}, Starttid: $formattedStart, Sluttid: $formattedEnd');
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

      Parking? parkingToEnd = parkingRepo.getById(endParkingId);
      if (parkingToEnd == null) {
        print('Ingen parkering hittades med det angivna ID:t.');
        break;
      }

      if (parkingToEnd.sluttid != null) {
        print('Denna parkering är redan avslutad.');
        break; 
      }

      parkingToEnd.sluttid = DateTime.now();
      parkingRepo.update(endParkingId, parkingToEnd);
      print('Parkering med ID $endParkingId har avslutats.');
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

      parkingRepo.delete(deleteId);
      break;

    default: 
      print('Ogiltigt alternativ.');
  }
}
