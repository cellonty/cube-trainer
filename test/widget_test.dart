import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cfop_trainer/data/alg_data.dart';
import 'package:cfop_trainer/logic/alg_tools.dart';
import 'package:cfop_trainer/main.dart';
import 'package:cfop_trainer/services/app_state.dart';

void main() {
  test('every algorithm solves its case', () {
    var count = 0;
    for (final set in kAlgSets) {
      for (final c in set.cases) {
        for (final alg in c.algs) {
          expect(CubeChecks.solves(c.setup, alg, c.goal), isTrue, reason: '${c.id}: $alg');
          count++;
        }
      }
    }
    expect(count, kTotalAlgs);
  });

  test('every practice scramble is solved by its source algorithm', () {
    for (final set in kAlgSets) {
      for (final c in set.cases) {
        for (var i = 0; i < c.scrambles.length; i++) {
          // -1 means the scramble is the case setup itself, so the main alg solves it.
          final from = c.scrambleFrom[i];
          final alg = c.algs[from < 0 ? 0 : from];
          expect(CubeChecks.solves(c.scrambles[i], alg, c.goal), isTrue, reason: '${c.id}: ${c.scrambles[i]}');
        }
      }
    }
  });

  testWidgets('app starts', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.create();
    await tester.pumpWidget(CubeTrainerApp(state: state));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
