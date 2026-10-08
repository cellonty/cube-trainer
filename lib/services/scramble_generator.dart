import 'dart:math';

class ScrambleGenerator {
  static const _moves = ['U', 'D', 'L', 'R', 'F', 'B'];
  static const _suffixes = ['', "'", '2'];

  static String generate([int length = 20]) {
    final rand = Random();
    final result = <String>[];
    String? last;

    for (var i = 0; i < length; i++) {
      String move;
      do {
        move = _moves[rand.nextInt(_moves.length)];
      } while (move == last);
      last = move;
      result.add('$move${_suffixes[rand.nextInt(_suffixes.length)]}');
    }
    return result.join(' ');
  }
}