// objectbox_handler.dart

// Globala variabler
import 'package:shared/shared.dart';

late final Store store;

// Funktion för att öppna och initiera ObjectBox
Future<void> initStore() async {
  store = await openStore(); 
}

// Funktion för att öppna databasen och returnera Store
Future<Store> openStore() async {
  return Store(
      getObjectBoxModel());
}

// Funktion för att stänga databasen
Future<void> closeStore() async {
  try {
    store.close(); // Stänger databasen
    print('Store stängd.'); // Bekräftelse på stängning
  } catch (e) {
    print('Misslyckades med att stänga store: $e'); 
  }
}




