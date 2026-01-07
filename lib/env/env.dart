
// This file will be generated in Step 4
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'PLANT_KEY', obfuscate: true)
  static final String plantKey = _Env.plantKey;
}
