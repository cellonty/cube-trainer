import 'alg_inverter.dart';

class RouxCMLLModel {
  final String name;
  final String alg;
  bool isFavorite;

  RouxCMLLModel({
    required this.name,
    required this.alg,
    this.isFavorite = false,
  });

  String get scramble => invertAlg(alg);
}

final List<RouxCMLLModel> rouxCMLLDatabase = [
  RouxCMLLModel(
    name: 'O Adjacent',
    alg: "R U R' F' R U R' U' R' F R2 U' R'",
  ),
  RouxCMLLModel(
    name: 'O Diagonal',
    alg: "F R U' R' U' R U R' F' R U R' U' R' F R F'",
  ),

  RouxCMLLModel(
    name: 'H Columns',
    alg: "U R U R' U R U' R' U R U2 R'",
  ),
  RouxCMLLModel(
    name: 'H Rows',
    alg: "F R U R' U' R U R' U' R U R' U' F'",
  ),
  RouxCMLLModel(
    name: 'H Column',
    alg: "R' F2 D R2 U R2 D' F2 R",
  ),
  RouxCMLLModel(
    name: 'H Row',
    alg: "U2 r U' r2 D' r U' r' D r2 U r'",
  ),

  RouxCMLLModel(
    name: 'Pi Right Bar',
    alg: "F R U R' U' R U R' U' F'",
  ),
  RouxCMLLModel(
    name: 'Pi Down Slash',
    alg: "U2 L' U2 L U L' U' L U2 L F' L' F",
  ),
  RouxCMLLModel(
    name: 'Pi X',
    alg: "R' F2 D R2 U' R2 D' F2 R",
  ),
  RouxCMLLModel(
    name: 'Pi Up Slash',
    alg: "R U2 R' U' R U R' U2 R' F R F'",
  ),
  RouxCMLLModel(
    name: 'Pi Columns',
    alg: "U r U' r2 D' r U r' D r2 U r'",
  ),
  RouxCMLLModel(
    name: 'Pi Left Bar',
    alg: "U' R' U' R' F R F' R U' R' U2 R",
  ),

  RouxCMLLModel(
    name: 'U Up Slash',
    alg: "U2 R2 D R' U2 R D' R' U2 R'",
  ),
  RouxCMLLModel(
    name: 'U Down Slash',
    alg: "R2 D' R U2 R' D R U2 R",
  ),
  RouxCMLLModel(
    name: 'U Bottom Row',
    alg: "R' U' R U' R' U2 R2 U R' U R U2 R'",
  ),
  RouxCMLLModel(
    name: 'U Rows',
    alg: "U' F R2 D R' U R D' R2 U' F'",
  ),
  RouxCMLLModel(
    name: 'U X',
    alg: "R' D R U' R U' R' U R' D' R U",
  ),
  RouxCMLLModel(
    name: 'U Upper Row',
    alg: "F R U R' U' F'",
  ),

  RouxCMLLModel(
    name: 'T Left Bar',
    alg: "U R U R' U' R' F R F'",
  ),
  RouxCMLLModel(
    name: 'T Right Bar',
    alg: "U L' U' L U L F' L' F",
  ),
  RouxCMLLModel(
    name: 'T Rows',
    alg: "R U2 R' U' R U' R2 U2 R U R' U R",
  ),
  RouxCMLLModel(
    name: 'T Bottom Row',
    alg: "R' U R U2 L' R' U R U' L",
  ),
  RouxCMLLModel(
    name: 'T Top Row',
    alg: "R' U' R U' R' U2 R2 U R' U R U2 R'",
  ),
  RouxCMLLModel(
    name: 'T Columns',
    alg: "R' U R2 D r' U2 r D' R2 U' R",
  ),

  RouxCMLLModel(
    name: 'Sune Left Bar',
    alg: "U R U R' U R U2 R'",
  ),
  RouxCMLLModel(
    name: 'Sune X',
    alg: "U L' U2 L U2 r U' r' F",
  ),
  RouxCMLLModel(
    name: 'Sune Up Slash',
    alg: "U F R' F' R U2 R U2 R'",
  ),
  RouxCMLLModel(
    name: 'Sune Columns',
    alg: "U R U R' U' R' F R F' R U R' U R U2 R'",
  ),
  RouxCMLLModel(
    name: 'Sune Right Bar',
    alg: "U' R U R' U R' F R F' R U2 R'",
  ),
  RouxCMLLModel(
    name: 'Sune Down Slash',
    alg: "U R U' L' U R' U' L",
  ),

  RouxCMLLModel(
    name: 'AS Right Bar',
    alg: "U' L' U' L U' L' U2 L",
  ),
  RouxCMLLModel(
    name: 'AS Columns',
    alg: "U' L' U' L U L' F' L' U' L U' L' U2 L",
  ),
  RouxCMLLModel(
    name: 'AS Diagonal BR',
    alg: "R' U' R U' R' U2 R",
  ),
  RouxCMLLModel(
    name: 'AS Diagonal FL',
    alg: "R' U' R U' R' U R' F R F' U R",
  ),
  RouxCMLLModel(
    name: 'AS Column Random',
    alg: "U2 R2 D R' U R D' R' U R' U' R U' R'",
  ),
  RouxCMLLModel(
    name: 'AS Row Random',
    alg: "U2 F' r U r' U2 r' F2 r",
  ),

  RouxCMLLModel(
    name: 'L Mirror',
    alg: "F R U' R' U' R U R' F'",
  ),
  RouxCMLLModel(
    name: 'L Inverse',
    alg: "F R' F' R U R U' R'",
  ),
  RouxCMLLModel(
    name: 'L Pure',
    alg: "R U2 R' U' R U R' U' R U R' U' R U' R'",
  ),
  RouxCMLLModel(
    name: 'L Front Commutator',
    alg: "R U2 R D R' U2 R D' R2",
  ),
  RouxCMLLModel(
    name: 'L Diagonal',
    alg: "R' U' R U R' F' R U R' U' R' F R2",
  ),
  RouxCMLLModel(
    name: 'L Back Commutator',
    alg: "R' U2 R' D' R U2 R' D R2",
  ),

  RouxCMLLModel(
    name: 'Headlights Front Row',
    alg: "R' U' R U' R' U2 R2 U R' U R U2 R'",
  ),
  RouxCMLLModel(
    name: 'Headlights 2 Rows Slash',
    alg: "R' F R U' R' U' R U R' F' R U R' U' R' F R F' R",
  ),
  RouxCMLLModel(
    name: 'Headlights Backslash',
    alg: "R' F R U R' F' R U F U2 F'",
  ),
  RouxCMLLModel(
    name: 'Blinkers Left Column',
    alg: "U' R U R' U' R' F R F'",
  ),
  RouxCMLLModel(
    name: 'Blinkers Right Column',
    alg: "U L' U' L U L F' L' F",
  ),
];