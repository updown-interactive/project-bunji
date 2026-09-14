
import 'package:bunji/features/home/viewcontroller/home_vc.dart';
import 'package:bunji/shared/services/database/database_service.dart';
import 'package:get_it/get_it.dart';

void registerHome(GetIt sl) { 
  sl.registerFactory(() => HomeViewController(databaseService: sl<DatabaseService>()));
}