import '../Models/person.dart';
import 'package:mycarparkingapp/objectbox.g.dart';

class PersonRepository {
  final Box<Person> _personBox;

  PersonRepository(Store store) : _personBox = store.box<Person>();

  // Hämtar en person med ett specifikt personnummer
  Future<Person?> getByPersonNumber(String personNumber) async {
    return _personBox
        .query(Person_.personNumber.equals(personNumber))
        .build()
        .findFirst(); 
  }

  // Skapar en ny person om ingen med samma personnummer finns
  Future<Person?> create(Person person) async {
    // Kollar om en person med samma personnummer redan finns
    Person? existingPerson = await getByPersonNumber(person.personNumber!);
    if (existingPerson != null) {
      print(
          'Fel: En person med personnummer ${person.personNumber} finns redan.');
      return null;
    }

    // Sparar den nya personen i databasen
    print('Skapar ny person med personnummer ${person.personNumber}');
    person.id = _personBox
        .put(person); 
    print('Ny person skapad med ID: ${person.id}');
    return person;
  }

  // Hämtar alla personer och loggar hur många som finns
  Future<List<Person>> getAll() async {
    final persons =
        _personBox.getAll(); 
    return persons;
  }

  // Hämtar en person via ID
  Future<Person?> getById(int id) async {
    return _personBox.get(id); 
  }

  // Uppdatera en person med nytt innehåll
  Future<Person?> update(int id, Person updatedPerson) async {
    var existingPerson =
         _personBox.get(id); 
    if (existingPerson != null) {
      updatedPerson.id = id;
      _personBox.put(
          updatedPerson); 
      print('Person med ID $id uppdaterad');
      return updatedPerson;
    }
    print('Ingen person hittades med ID $id för uppdatering');
    return null;
  }

  // Tar bort en person baserat på personnummer
  Future<bool> deleteByPersonNumber(String personNumber) async {
    final person = _personBox
        .query(Person_.personNumber.equals(personNumber))
        .build()
        .findFirst(); 

    if (person != null) {
      print('Person med personnummer $personNumber raderad');
      _personBox
          .remove(person.id); 
      return true;
    }

    print('Ingen person hittades med personnummer $personNumber för radering');
    return false; 
  }
}
