import 'package:flutter/material.dart';
import '../widgets/algorithm_card.dart';
import '../services/favorite_service.dart';
import '../l10n/app_localizations.dart';

class TrainingScreen extends StatefulWidget {
  final String title;
  final List<dynamic> algorithms;
  const TrainingScreen({
    Key? key,
    required this.title,
    required this.algorithms,
  }) : super(key: key);

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _favService = FavoriteService();
  final _searchController = TextEditingController();

  Set<String> _favorites = {};
  bool _onlyFavorites = false;
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  int _columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1400) return 3;
    return 4;
  }

  double _previewSize(double width) {
    if (width < 600) return 90;
    if (width < 900) return 110;
    return 130;
  }

  List<dynamic> _filtered() {
    return widget.algorithms.where((a) {
      final name = a.name as String;
      if (_onlyFavorites && !_favorites.contains(name)) return false;
      if (_searchQuery.isNotEmpty &&
          !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final t = AppLocalizations.of(context);
    final list = _filtered();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_onlyFavorites ? Icons.favorite : Icons.favorite_border),
            tooltip: t.onlyFavoritesTooltip,
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: t.searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.primary.withOpacity(0.06),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${list.length} '
                '${list.length == 1 ? t.algorithmSingular : t.algorithmPlural}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),

          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.noAlgorithms,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = _columnsFor(constraints.maxWidth);
                      final preview = _previewSize(constraints.maxWidth);

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: cols == 1 ? 2.6 : 2.2,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final a = list[i];
                          return AlgorithmCard(
                            name: a.name as String,
                            alg: a.alg as String,
                            scramble: a.scramble as String?,
                            isFavorite: _favorites.contains(a.name),
                            previewSize: preview,
                            onFavoriteToggle: () =>
                                _toggleFav(a.name as String),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}