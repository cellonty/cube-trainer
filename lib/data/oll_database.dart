import 'alg_inverter.dart';

class OLLModel {
  final String name;
  final String alg;
  bool isFavorite;

  OLLModel({
    required this.name,
    required this.alg,
    this.isFavorite = false,
  });

  String get scramble => invertAlg(alg);
}

final List<OLLModel> ollDatabase = [
  OLLModel(name: 'OLL 1',  alg: "R U2' R2' F R F' U2 R' F R F'"),
  OLLModel(name: 'OLL 2',  alg: "F R U R' U' F' f R U R' U' f'"),
  OLLModel(name: 'OLL 3',  alg: "f R U R' U' f' U' F R U R' U' F'"),
  OLLModel(name: 'OLL 4',  alg: "f R U R' U' f' U F R U R' U' F'"),
  OLLModel(name: 'OLL 5',  alg: "r' U2' R U R' U r"),
  OLLModel(name: 'OLL 6',  alg: "r U2 R' U' R U' r'"),
  OLLModel(name: 'OLL 7',  alg: "r U R' U R U2' r'"),
  OLLModel(name: 'OLL 8',  alg: "r' U' R U' R' U2 r"),
  OLLModel(name: 'OLL 9',  alg: "R U R' U' R' F R2 U R' U' F'"),
  OLLModel(name: 'OLL 10', alg: "R U R' U R' F R F' R U2' R'"),
  OLLModel(name: 'OLL 11', alg: "r' R2 U R' U R U2 R' U M'"),
  OLLModel(name: 'OLL 12', alg: "M' R' U' R U' R' U2 R U' M"),
  OLLModel(name: 'OLL 13', alg: "r U' r' U' r U r' y' R' U R"),
  OLLModel(name: 'OLL 14', alg: "R' F R U R' F' R F U' F'"),
  OLLModel(name: 'OLL 15', alg: "r' U' r R' U' R U r' U r"),
  OLLModel(name: 'OLL 16', alg: "r U r' R U R' U' r U' r'"),
  OLLModel(name: 'OLL 17', alg: "R U R' U R' F R F' U2' R' F R F'"),
  OLLModel(name: 'OLL 18', alg: "r U R' U R U2 r2 U' R U' R' U2 r"),
  OLLModel(name: 'OLL 19', alg: "M U R U R' U' M' R' F R F'"),
  OLLModel(name: 'OLL 20', alg: "M U R U R' U' M2' U R U' r'"),
  OLLModel(name: 'OLL 21', alg: "R U2 R' U' R U R' U' R U' R'"),
  OLLModel(name: 'OLL 22', alg: "R U2 R2 U' R2 U' R2 U2 R"),
  OLLModel(name: 'OLL 23', alg: "R2 D R' U2 R D' R' U2 R'"),
  OLLModel(name: 'OLL 24', alg: "r U R' U' r' F R F'"),
  OLLModel(name: 'OLL 25', alg: "F' r U R' U' r' F R"),
  OLLModel(name: 'OLL 26', alg: "R U2 R' U' R U' R'"),
  OLLModel(name: 'OLL 27', alg: "R U R' U R U2' R'"),
  OLLModel(name: 'OLL 28', alg: "r U R' U' M U R U' R'"),
  OLLModel(name: 'OLL 29', alg: "y R U R' U' R U' R' F' U' F R U R'"),
  OLLModel(name: 'OLL 30', alg: "F U R U2 R' U' R U2 R' U' F'"),
  OLLModel(name: 'OLL 31', alg: "R' U' F U R U' R' F' R"),
  OLLModel(name: 'OLL 32', alg: "R U B' U' R' U R B R'"),
  OLLModel(name: 'OLL 33', alg: "R U R' U' R' F R F'"),
  OLLModel(name: 'OLL 34', alg: "R U R2' U' R' F R U R U' F'"),
  OLLModel(name: 'OLL 35', alg: "R U2' R2' F R F' R U2' R'"),
  OLLModel(name: 'OLL 36', alg: "R' U' R U' R' U R U l U' R' U x"),
  OLLModel(name: 'OLL 37', alg: "F R U' R' U' R U R' F'"),
  OLLModel(name: 'OLL 38', alg: "R U R' U R U' R' U' R' F R F'"),
  OLLModel(name: 'OLL 39', alg: "L F' L' U' L U F U' L'"),
  OLLModel(name: 'OLL 40', alg: "R' F R U R' U' F' U R"),
  OLLModel(name: 'OLL 41', alg: "R U R' U R U2' R' F R U R' U' F'"),
  OLLModel(name: 'OLL 42', alg: "R' U' R U' R' U2 R F R U R' U' F'"),
  OLLModel(name: 'OLL 43', alg: "R' U' F' U F R"),
  OLLModel(name: 'OLL 44', alg: "f R U R' U' f'"),
  OLLModel(name: 'OLL 45', alg: "F R U R' U' F'"),
  OLLModel(name: 'OLL 46', alg: "R' U' R' F R F' U R"),
  OLLModel(name: 'OLL 47', alg: "F' L' U' L U L' U' L U F"),
  OLLModel(name: 'OLL 48', alg: "F R U R' U' R U R' U' F'"),
  OLLModel(name: 'OLL 49', alg: "r U' r2' U r2 U r2' U' r"),
  OLLModel(name: 'OLL 50', alg: "r' U r2 U' r2' U' r2 U r'"),
  OLLModel(name: 'OLL 51', alg: "f R U R' U' R U R' U' f'"),
  OLLModel(name: 'OLL 52', alg: "R' U' R U' R' U y' R' U R B"),
  OLLModel(name: 'OLL 53', alg: "r' U' R U' R' U R U' R' U2 r"),
  OLLModel(name: 'OLL 54', alg: "r U R' U R U' R' U R U2' r'"),
  OLLModel(name: 'OLL 55', alg: "y R' F R U R U' R2' F' R2 U' R' U R U R'"),
  OLLModel(name: 'OLL 56', alg: "r' U' r U' R' U R U' R' U R r' U r"),
  OLLModel(name: 'OLL 57', alg: "R U R' U' M' U R U' r'"),
];