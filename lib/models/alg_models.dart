enum Puzzle { cube3, cube2 }

enum Method { cfop, roux, cube2 }

/// What a case's algorithm has to achieve. Used by [AlgVerifier], the
/// grayscale mask and the case previews.
enum CaseGoal {
  f2l,
  oll,
  eo,
  ocll,
  pll,
  coll,
  ell,
  cmll,
  lseEo,
  lseEp,
  cll,
  eg1,
  eg2,
  ortegaOll,
  pbl,
}

extension CaseGoalX on CaseGoal {
  bool get isTwoByTwo =>
      this == CaseGoal.cll ||
      this == CaseGoal.eg1 ||
      this == CaseGoal.eg2 ||
      this == CaseGoal.ortegaOll ||
      this == CaseGoal.pbl;

  /// Cases that are best shown as a top (last layer) view.
  bool get isLastLayer =>
      this == CaseGoal.oll ||
      this == CaseGoal.eo ||
      this == CaseGoal.ocll ||
      this == CaseGoal.pll ||
      this == CaseGoal.coll ||
      this == CaseGoal.ell ||
      this == CaseGoal.cmll ||
      this == CaseGoal.cll ||
      this == CaseGoal.ortegaOll;
}

class AlgCase {
  /// Unique id. Also used as storage key (favorites, status, times).
  final String id;
  final String title;
  final String group;
  final CaseGoal goal;

  /// Moves that create the case from a solved cube (yellow top, green front).
  final String setup;

  /// Verified algorithms. The first one is the default.
  final List<String> algs;
  final List<String> sources;

  /// Verified scrambles that create this case.
  final List<String> scrambles;

  /// For each scramble: index of the algorithm it was generated from
  /// (inverse), or -1 for the SpeedCubeDB setup.
  final List<int> scrambleFrom;

  const AlgCase({
    required this.id,
    required this.title,
    required this.group,
    required this.goal,
    required this.setup,
    required this.algs,
    required this.sources,
    required this.scrambles,
    required this.scrambleFrom,
  });
}

class AlgSet {
  final String id;
  final String title;
  final Method method;
  final Puzzle puzzle;
  final String source;
  final List<AlgCase> cases;

  const AlgSet({
    required this.id,
    required this.title,
    required this.method,
    required this.puzzle,
    required this.source,
    required this.cases,
  });

  List<String> get groups {
    final out = <String>[];
    for (final c in cases) {
      if (!out.contains(c.group)) out.add(c.group);
    }
    return out;
  }
}

/// Learning status of a case.
enum LearnStatus { notLearned, learning, learned }
