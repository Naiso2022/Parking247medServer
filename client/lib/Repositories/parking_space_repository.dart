import 'package:shared/shared.dart'; 

class ParkingSpaceRepository {

  // TODO: remove store when no longer used

  late final Box<ParkingSpace> _parkingSpaceBox;

  ParkingSpaceRepository(Store store) {
    _parkingSpaceBox = store.box<ParkingSpace>();
  }

  /// Skapar en ny parkeringsplats i databasen
 Future<ParkingSpace> create(ParkingSpace parkingSpace) async {
  
    parkingSpace.id = 0;
    await Future(() => _parkingSpaceBox.put(parkingSpace));
    return parkingSpace;
  }

  /// Hämtar alla parkeringsplatser från databasen
  Future<List<ParkingSpace>> getAll() async {
    return await Future(() => _parkingSpaceBox.getAll());
  }

  /// Hämtar en specifik parkeringsplats baserat på dess ID
  Future<ParkingSpace?> getById(int id) async {
    return await Future(() => _parkingSpaceBox.get(id));
  }

  /// Uppdaterar en befintlig parkeringsplats i databasen
  Future<ParkingSpace?> update(int id, ParkingSpace updatedParkingSpace) async {
    var existingParkingSpace = await Future(() => _parkingSpaceBox.get(id));
    if (existingParkingSpace != null) {
      updatedParkingSpace.id = id; 
      await Future(() => _parkingSpaceBox.put(updatedParkingSpace));
      return updatedParkingSpace;
    }
    return null;
  }

  /// Tar bort en parkeringsplats baserat på dess ID
  Future<bool> delete(int id) async {
    return await Future(() => _parkingSpaceBox.remove(id));
  }

  /// Kontrollerar om ett givet ID redan finns i databasen
  bool idExists(int id) {
    final existingParkingSpace = _parkingSpaceBox.get(id);
    return existingParkingSpace !=
        null; // Returnerar true om ID finns, false annars
  }
}
