import 'alg_inverter.dart';

class RouxLSEModel {
  final String name;
  final String alg;
  bool isFavorite;

  RouxLSEModel({
    required this.name,
    required this.alg,
    this.isFavorite = false,
  });

  String get scramble => invertAlg(alg);
}

final List<RouxLSEModel> rouxLSEDatabase = [
  RouxLSEModel(name: 'EO Front Arrow', alg: "M' U M"),
  RouxLSEModel(name: 'EO Back Arrow', alg: "M U M'"),
  RouxLSEModel(name: 'EO Front 1/1', alg: "M U' M' U' M U' M'"),
  RouxLSEModel(name: 'EO Back 1/1', alg: "M' U' M U' M' U' M'"),
  RouxLSEModel(name: 'EO 2 Adj / 2', alg: "M2 U' M' U' M'"),
  RouxLSEModel(name: 'EO 2 Adj / 0', alg: "M' U' M' U2 M' U' M'"),
  RouxLSEModel(name: 'EO 2 Opp / 2', alg: "M' U2 M' U2 M U' M'"),
  RouxLSEModel(name: 'EO 2 Opp / 0', alg: "M' U' M U M' U' M'"),
  RouxLSEModel(name: 'EO 0 / 2', alg: "M' U' M' U M U' M'"),
  RouxLSEModel(name: 'EO 4 / 0', alg: "M' U2 M' U2 M' U' M'"),
  RouxLSEModel(name: 'EO All 6', alg: "M' U' M' U2 M' U' M U' M' U' M'"),

  RouxLSEModel(name: 'EP Ua', alg: "M2 U M U2 M' U M2"),
  RouxLSEModel(name: 'EP Ub', alg: "M2 U' M U2 M' U' M2"),
  RouxLSEModel(name: 'EP Z', alg: "M2 U M2 U M' U2 M2 U2 M'"),
  RouxLSEModel(name: 'EP H', alg: "M2 U' M2 U2 M2 U' M2"),
];