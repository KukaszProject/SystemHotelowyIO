import 'package:systemhotelowy/interfaces/i_system_platnosci.dart';

class FakeSystemPlatnosci implements ISystemPlatnosci {
  
  @override
  bool przetworzPlatnosc(double calkowitaKwota) {
    return true;
  }
}