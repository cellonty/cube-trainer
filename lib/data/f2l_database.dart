import 'alg_inverter.dart';

class F2LModel {
  final String name;
  final String alg;
  bool isFavorite;

  F2LModel({
    required this.name,
    required this.alg,
    this.isFavorite = false,
  });

  String get scramble => invertAlg(alg);
}

final List<F2LModel> f2lDatabase = [
  F2LModel(name: 'F2L 1',  alg: "U R U' R'"),
  F2LModel(name: 'F2L 2',  alg: "y' U' R' U R"),
  F2LModel(name: 'F2L 3',  alg: "F' U' F"),
  F2LModel(name: 'F2L 4',  alg: "R U R'"),

  F2LModel(name: 'F2L 5',  alg: "U' R U R' U2 R U' R'"),
  F2LModel(name: 'F2L 6',  alg: "U' r U' R' U R U r'"),
  F2LModel(name: 'F2L 7',  alg: "U' R U2 R' U' R U2 R'"),
  F2LModel(name: 'F2L 8',  alg: "r' U2 R2 U R2 U r"),

  F2LModel(name: 'F2L 9',  alg: "U' R U' R' U F' U' F"),
  F2LModel(name: 'F2L 10', alg: "U' R U R' U R U R'"),
  F2LModel(name: 'F2L 11', alg: "U' R U2 R' U F' U' F"),
  F2LModel(name: 'F2L 12', alg: "R U' R' U R U' R' U2 R U' R'"),
  F2LModel(name: 'F2L 13', alg: "y' U R' U R U' R' U' R"),
  F2LModel(name: 'F2L 14', alg: "U' R U' R' U R U R'"),
  F2LModel(name: 'F2L 15', alg: "R U R' U2 R U' R' U R U' R'"),

  F2LModel(name: 'F2L 16', alg: "R U' R' U2 F' U' F"),
  F2LModel(name: 'F2L 17', alg: "R U2 R' U' R U R'"),
  F2LModel(name: 'F2L 18', alg: "F' U2 F U F' U' F"),
  F2LModel(name: 'F2L 19', alg: "U R U2 R' U R U' R'"),
  F2LModel(name: 'F2L 20', alg: "U' R U' R2 F R F' R U' R'"),
  F2LModel(name: 'F2L 21', alg: "R U' R' U2 R U R'"),

  F2LModel(name: 'F2L 22', alg: "F' L' U2 L F"),
  F2LModel(name: 'F2L 23', alg: "R U R' U2 R U R' U' R U R'"),
  F2LModel(name: 'F2L 24', alg: "F U R U' R' F' R U' R'"),

  F2LModel(name: 'F2L 25', alg: "U' R' F R F' R U R'"),
  F2LModel(name: 'F2L 26', alg: "U R U' R' F R' F' R"),
  F2LModel(name: 'F2L 27', alg: "R U' R' U R U' R'"),
  F2LModel(name: 'F2L 28', alg: "R U R' U' F R' F' R"),
  F2LModel(name: 'F2L 29', alg: "R' F R F' U R U' R'"),
  F2LModel(name: 'F2L 30', alg: "R U R' U' R U R'"),

  F2LModel(name: 'F2L 31', alg: "U' R' F R F' R U' R'"),
  F2LModel(name: 'F2L 32', alg: "R U R' U' R U R' U' R U R'"),
  F2LModel(name: 'F2L 33', alg: "U' R U' R' U2 R U' R'"),
  F2LModel(name: 'F2L 34', alg: "U R U R' U2 R U R'"),
  F2LModel(name: 'F2L 35', alg: "U' R U R' U F' U' F"),
  F2LModel(name: 'F2L 36', alg: "U F' U' F U' R U R'"),
  F2LModel(name: 'F2L 37', alg: "R2 U2 F R2 F' U2 R' U R'"),
  F2LModel(name: 'F2L 38', alg: "R U' R' U' R U R' U2 R U' R'"),
  F2LModel(name: 'F2L 39', alg: "R U' R' U R U2 R' U R U' R'"),
  F2LModel(name: 'F2L 40', alg: "F' L' U2 L F R U R'"),
  F2LModel(name: 'F2L 41', alg: "R U' R' r U' r' U2 r U r'"),
];