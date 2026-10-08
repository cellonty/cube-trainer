import 'alg_inverter.dart';

class PLLModel {
  final String name;
  final String alg;
  bool isFavorite;

  PLLModel({
    required this.name,
    required this.alg,
    this.isFavorite = false,
  });

  String get scramble => invertAlg(alg);
}

final List<PLLModel> pllDatabase = [
  PLLModel(name: 'PLL Aa', alg: "x R' U R' D2 R U' R' D2 R2 x'"),
  PLLModel(name: 'PLL Ab', alg: "x R2 D2 R U R' D2 R U' R x'"),
  PLLModel(name: 'PLL E',  alg: "x' R U' R' D R U R' D' R U R' D R U' R' D' x"),
  PLLModel(name: 'PLL F',  alg: "R' U' F' R U R' U' R' F R2 U' R' U' R U R' U R"),
  PLLModel(name: 'PLL Ga', alg: "R2 U R' U R' U' R U' R2 D U' R' U R D'"),
  PLLModel(name: 'PLL Gb', alg: "R' U' R U D' R2 U R' U R U' R U' R2 D"),
  PLLModel(name: 'PLL Gc', alg: "R2 U' R U' R U R' U R2 D' U R U' R' D"),
  PLLModel(name: 'PLL Gd', alg: "R U R' U' D R2 U' R U' R' U R' U R2 D'"),
  PLLModel(name: 'PLL H',  alg: "M2 U' M2 U2 M2 U' M2"),
  PLLModel(name: 'PLL Ja', alg: "R' U L' U2 R U' R' U2 R L"),
  PLLModel(name: 'PLL Jb', alg: "R U R' F' R U R' U' R' F R2 U' R'"),
  PLLModel(name: 'PLL Na', alg: "R U R' U R U R' F' R U R' U' R' F R2 U' R' U2 R U' R'"),
  PLLModel(name: 'PLL Nb', alg: "F r' F' r U r U' r2 D' F r U r' F' D r"),
  PLLModel(name: 'PLL Ra', alg: "R U' R' U' R U R D R' U' R D' R' U2 R'"),
  PLLModel(name: 'PLL Rb', alg: "R' U2 R U2 R' F R U R' U' R' F' R2"),
  PLLModel(name: 'PLL T',  alg: "R U R' U' R' F R2 U' R' U' R U R' F'"),
  PLLModel(name: 'PLL Ua', alg: "M2 U' M' U2 M U' M2"),
  PLLModel(name: 'PLL Ub', alg: "M2 U M' U2 M U M2"),
  PLLModel(name: 'PLL V',  alg: "R' U R' U' y R' F' R2 U' R' U R' F R F"),
  PLLModel(name: 'PLL Y',  alg: "F R U' R' U' R U R' F' R U R' U' R' F R F'"),
  PLLModel(name: 'PLL Z',  alg: "M2 U M2 U M' U2 M2 U2 M' U2"),
];