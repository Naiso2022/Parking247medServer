
import 'package:shared/shared.dart';


class VehicleRepository {

  // TODO: remove store when no longer used
 
  late final Box<Vehicle> _vehicleBox;
  late final Box<Person> _personBox;
  late final Box<Parking> _parkingBox;

  VehicleRepository(Store store) {
    _vehicleBox = store.box<Vehicle>();
    _personBox = store.box<Person>();
    _parkingBox = store.box<Parking>();
  }

  // Skapar fordon
  Future<Vehicle> create(Vehicle vehicle) async {
    vehicle.id = 0; // Sätt ID till 0 för att generera ett nytt ID
    _vehicleBox.put(vehicle); // Sätt objektet i databasen
    return vehicle; // Returnera det skapade objektet
  }

  // Hämtar alla fordon
  Future<List<Vehicle>> getAll() async {
    final vehicles = _vehicleBox.getAll();
    return vehicles;
  }

  // Hämtar fordon efter ID
  Future<Vehicle?> getById(int id) async {
    return _vehicleBox.get(id);
  }

  // Uppdaterar fordon
  Future<bool> update(int id, Vehicle updatedVehicle) async {
    try {
      updatedVehicle.id = id;
      int result = _vehicleBox.put(updatedVehicle);
      return result > 0;
    } catch (e) {
      print('Fel vid uppdatering av fordon: $e');
      return false;
    }
  }

  // Ta bort fordon efter ID 
  Future<bool> delete(int id) async {
    try {
      _vehicleBox.remove(id);
      return true;
    } catch (e) {
      print("Fel vid borttagning av fordon: $e");
      return false;
    }
  }

  // Hämtar ägar-ID med personnummer
  Future<int?> getOwnerIdByPersonNumber(String personNumber) async {
    try {
      final person = _personBox
          .query(Person_.personNumber.equals(personNumber))
          .build()
          .findFirst();
      return person?.id;
    } catch (e) {
      print("Fel vid hämtning av ownerId: $e");
      return null;
    }
  }

  // Tar bort fordon efter registreringsnummer
  Future<bool> deleteByRegistreringsnummer(String registreringsnummer) async {
    try {
      final vehicle = _vehicleBox
          .query(Vehicle_.registrationNumber.equals(registreringsnummer))
          .build()
          .findFirst();

      if (vehicle != null) {
        final parkeringar = _parkingBox
            .query(Parking_.vehicleId.equals(vehicle.id))
            .build()
            .find();

        for (final parking in parkeringar) {
          parking.endTime = DateTime.now();
          _parkingBox.put(parking);
        }

        _vehicleBox.remove(vehicle.id);
        print(
            "Fordon med registreringsnummer $registreringsnummer och alla dess parkeringar har avslutats och tagits bort (om det fanns några).");
        return true;
      } else {
        print(
            "Inget fordon hittades med registreringsnummer $registreringsnummer.");
        return false;
      }
    } catch (e) {
      print("Fel vid borttagning av fordon och dess parkeringar: $e");
      return false;
    }
  }

  // Hämtar fordon efter registreringsnummer
  Future<Vehicle?> getByRegistreringsnummer(String registreringsnummer) async {
    try {
      final vehicle = _vehicleBox
          .query(Vehicle_.registrationNumber.equals(registreringsnummer))
          .build()
          .findFirst();
      return vehicle;
    } catch (e) {
      print("Fel vid hämtning av fordon med registreringsnummer: $e");
      return null;
    }
  }

  // Tar bort alla fordon kopplade till en ägare
  Future<void> deleteByOwner(String ownerPersonNumber) async {
    try {
      final ownerId = await getOwnerIdByPersonNumber(ownerPersonNumber);

      if (ownerId == null) {
        print("Ingen ägare hittades med det angivna personnumret.");
        return;
      }

      final vehiclesToDelete =
          _vehicleBox.query(Vehicle_.ownerId.equals(ownerId)).build().find();

      for (final vehicle in vehiclesToDelete) {
        _vehicleBox.remove(vehicle.id);
      }

      print(
          "Alla fordon kopplade till ägaren med personnummer $ownerPersonNumber har tagits bort.");
    } catch (e) {
      print("Fel vid borttagning av fordon: $e");
    }
  }

  // Hämtar alla fordon kopplade till en ägare
  Future<List<Vehicle>> getByOwner({String? personNum}) async {
    try {
      if (personNum == null || personNum.isEmpty) {
        print("Personnummer kan inte vara tomt.");
        return [];
      }

      final person = _personBox
          .query(Person_.personNumber.equals(personNum))
          .build()
          .findFirst();

      if (person != null) {
        final vehicles = _vehicleBox
            .query(Vehicle_.ownerId.equals(person.id))
            .build()
            .find();
        return vehicles;
      } else {
        print("Ingen person med personnummer $personNum hittades.");
        return [];
      }
    } catch (e) {
      print("Fel vid hämtning av fordon: $e");
      return [];
    }
  }
}
