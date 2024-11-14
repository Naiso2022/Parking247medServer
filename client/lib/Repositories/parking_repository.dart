import 'package:mycarparkingapp/Repositories/parking_space_repository.dart';
import 'package:shared/shared.dart';

/// Repository för hantering av parkeringsobjekt
class ParkingRepository {

  // TODO: remove store when no longer used

  late final Box<Parking> _parkingBox;
  late final Box<Vehicle> _vehicleBox;
  late final ParkingSpaceRepository parkingSpaceRepo;

  /// Konstruktor: Initierar _parkingBox, _vehicleBox och parkingSpaceRepo
  ParkingRepository(Store store, this.parkingSpaceRepo) {
    _parkingBox = store.box<Parking>();
    _vehicleBox = store.box<Vehicle>();
  }

  /// Skapar ett nytt parkeringsobjekt i databasen
  Future<Parking> create(Parking parking) async {
    // TODO: REWRITE LIKE THIS:

    /* 
    
     // send item serialized as json over http to server at localhost:8080
    final uri = Uri.parse("http://localhost:8080/items");

    Response response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()));

    final json = jsonDecode(response.body);

    return Item.fromJson(json);
    
     */

    Parking? ongoingParking =
        await getOngoingParking(parking.vehicleId, parking.parkingSpaceId);

    if (ongoingParking != null) {
      throw Exception(
          'Det finns redan en pågående parkering för detta fordon på denna parkeringsplats.');
    }

    parking.id = 0; // Nollställ ID
    await Future(() => _parkingBox.put(parking));
    return parking;
  }

  /// Hämtar alla parkeringsobjekt från databasen
  Future<List<Parking>> getAll() async {
    return await Future(() => _parkingBox.getAll());
  }

  /// Hämtar alla parkeringar med detaljer om fordon och parkeringsplats
  Future<List<Map<String, dynamic>>> getAllWithDetails() async {
    final parkings = await getAll();
    final parkingDetails = <Map<String, dynamic>>[];

    for (final parking in parkings) {
      final vehicle = _vehicleBox.get(parking.vehicleId);
      // Försök hämta parkeringsplatsen baserat på parkingSpaceId
      final parkingSpace =
          await parkingSpaceRepo.getById(parking.parkingSpaceId);

      // Kontrollera att parkeringsplatsen finns
      if (vehicle != null && parkingSpace != null) {
        parkingDetails.add({
          'parking': parking,
          'vehicle': vehicle.registrationNumber,
          'parkingSpace': parkingSpace.address,
        });
      } else {
        parkingDetails.add({
          'parking': parking,
          'vehicle':
              vehicle != null ? vehicle.registrationNumber : 'Borttaget fordon',
          'parkingSpace':
              parkingSpace != null ? parkingSpace.address : 'Borttagen plats',
        });
      }
    }

    return parkingDetails;
  }

  /// Hämtar ett specifikt parkeringsobjekt baserat på dess ID
  Future<Parking?> getById(int id) async {
    return await Future(() => _parkingBox.get(id));
  }

  /// Uppdaterar ett befintligt parkeringsobjekt i databasen
  Future<Parking?> update(int id, Parking updatedParking) async {
    var existingParking = await Future(() => _parkingBox.get(id));
    if (existingParking != null) {
      updatedParking.id = id;
      await Future(() => _parkingBox.put(updatedParking));
      return updatedParking;
    }
    return null;
  }

  /// Tar bort ett parkeringsobjekt baserat på dess ID
  Future<bool> delete(int id) async {
    return await Future(() => _parkingBox.remove(id));
  }

  /// Hämtar nästa lediga ID för en parkering
  Future<int> getNextAvailableId() async {
    List<Parking> allParkings = await getAll();
    int maxId = allParkings.isNotEmpty
        ? allParkings.map((p) => p.id).reduce((a, b) => a > b ? a : b)
        : 0;
    return maxId + 1;
  }

  /// Hämtar en pågående parkering för ett fordon och parkeringsplats
  Future<Parking?> getOngoingParking(int vehicleId, int parkingSpaceId) async {
    final query = _parkingBox
        .query(Parking_.parkingSpaceId.equals(parkingSpaceId) &
            Parking_.vehicleId.equals(vehicleId) &
            Parking_.endTime.isNull())
        .build();

    List<Parking> ongoingParkings = query.find();
    if (ongoingParkings.isNotEmpty) {
      final vehicle = _vehicleBox.get(vehicleId);

      if (vehicle == null) {
        print('Fordonet med ID: $vehicleId finns inte längre.');
        return null;
      }
      return ongoingParkings.first;
    }
    return null;
  }
}
