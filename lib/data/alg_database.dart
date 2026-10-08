import 'f2l_database.dart';
import 'oll_database.dart';
import 'pll_database.dart';
import 'roux_cmll_database.dart';
import 'roux_lse_database.dart';

class AlgDatabase {
  static List<F2LModel> get f2l => f2lDatabase;
  static List<OLLModel> get oll => ollDatabase;
  static List<PLLModel> get pll => pllDatabase;

  static List<RouxCMLLModel> get rouxCMLL => rouxCMLLDatabase;
  static List<RouxLSEModel> get rouxLSE => rouxLSEDatabase;
}