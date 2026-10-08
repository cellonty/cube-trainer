import 'package:flutter/material.dart';
import '../widgets/algorithm_card.dart';
import '../services/favorite_service.dart';
import '../data/roux_cmll_database.dart';
import '../data/roux_lse_database.dart';

class RouxScreen extends StatefulWidget {
  const RouxScreen({Key? key}) : super(key: key);

  @override
  State<RouxScreen> createState() => _RouxScreenState();
}

class _RouxScreenState extends State<RouxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roux'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CMLL'),
            Tab(text: 'LSE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AlgListTab(items: _cmllItems),
          _AlgListTab(items: _lseItems),
        ],
      ),
    );
  }
}

class _AlgItem {
  final String name;
  final String alg;
  final String scramble;
  const _AlgItem(this.name, this.alg, this.scramble);
}

final _cmllItems = rouxCMLLDatabase
    .map((m) => _AlgItem(m.name, m.alg, m.scramble))
    .toList();

final _lseItems = rouxLSEDatabase
    .map((m) => _AlgItem(m.name, m.alg, m.scramble))
    .toList();

class _AlgListTab extends StatefulWidget {
  final List<_AlgItem> items;
  const _AlgListTab({required this.items});

  @override
  State<_AlgListTab> createState() => _AlgListTabState();
}

class _AlgListTabState extends State<_AlgListTab> {
  final _favService = FavoriteService();
  Set<String> _favorites = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _favorites = await _favService.loadAll();
    setState(() => _loading = false);
  }

  Future<void> _toggleFav(String name) async {
    final nowFav = !_favorites.contains(name);
    await _favService.toggle(name, nowFav);
    setState(() {
      if (nowFav) {
        _favorites.add(name);
      } else {
        _favorites.remove(name);
      }
    });
  }

  int _columnsFor(double w) {
    if (w < 600) return 1;
    if (w < 900) return 2;
    if (w < 1400) return 3;
    return 4;
  }

  double _previewSize(double w) {
    if (w < 600) return 90;
    if (w < 900) return 110;
    return 130;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No algorithms yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnsFor(constraints.maxWidth);
        final preview = _previewSize(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: cols == 1 ? 2.6 : 2.2,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, i) {
            final a = widget.items[i];
            return AlgorithmCard(
              name: a.name,
              alg: a.alg,
              scramble: a.scramble,
              isFavorite: _favorites.contains(a.name),
              previewSize: preview,
              onFavoriteToggle: () => _toggleFav(a.name),
            );
          },
        );
      },
    );
  }
}