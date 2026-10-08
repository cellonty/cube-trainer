String invertAlg(String alg) {
  final moves = alg.trim().split(RegExp(r'\s+'));
  return moves.reversed.map((m) {
    if (m.endsWith("2'")) return m.substring(0, m.length - 2) + '2';
    if (m.endsWith("'")) return m.substring(0, m.length - 1);
    if (m.endsWith('2')) return m;
    return "$m'";
  }).join(' ');
}