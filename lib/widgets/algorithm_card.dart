import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/rubiks_cube.dart';
import '../l10n/app_localizations.dart';
import 'cube_preview_3d.dart';
import 'cube_top_view.dart';

class AlgorithmCard extends StatefulWidget {
  final String name;
  final String alg;
  final String? scramble;
  final bool isFavorite;
  final double previewSize;
  final VoidCallback onFavoriteToggle;

  const AlgorithmCard({
    Key? key,
    required this.name,
    required this.alg,
    this.scramble,
    required this.isFavorite,
    this.previewSize = 110,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<AlgorithmCard> createState() => _AlgorithmCardState();
}

class _AlgorithmCardState extends State<AlgorithmCard> {
  RubiksCube? _cube;
  List<List<int>>? _arrows;

  @override
  void initState() {
    super.initState();
    _buildCube();
  }

  @override
  void didUpdateWidget(covariant AlgorithmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scramble != widget.scramble) _buildCube();
  }

  void _buildCube() {
    if (widget.scramble == null) {
      _cube = null;
      _arrows = null;
      return;
    }
    final c = RubiksCube();
    c.applyScramble(widget.scramble!);
    _cube = c;

    if (widget.name.startsWith('PLL')) {
      _arrows = c.computePllArrows();
    } else {
      _arrows = null;
    }
  }

  bool get _isF2L => widget.name.startsWith('F2L');

  Widget _buildPreview() {
    if (_cube == null) return const SizedBox.shrink();
    if (_isF2L) {
      return CubePreview3D(cube: _cube!, size: widget.previewSize);
    }
    return CubeTopView(
      cube: _cube!,
      size: widget.previewSize,
      arrows: _arrows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreview(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _favButton(theme),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _algBox(context, t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _favButton(ThemeData theme) {
    return InkWell(
      onTap: widget.onFavoriteToggle,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: widget.isFavorite
              ? Colors.red
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _algBox(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              widget.alg,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.alg));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${t.alg} ${t.copied}'),
                  duration: const Duration(milliseconds: 700),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}