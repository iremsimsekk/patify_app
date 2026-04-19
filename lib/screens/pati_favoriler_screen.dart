import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/guide_mock_data.dart';
import '../data/pati_keyfi_mock_data.dart';
import '../widgets/pati_module_ui.dart';
import 'pati_keyfi_detail_screen.dart';
import 'rehber_detail_screen.dart';

class PatiFavorilerScreen extends StatefulWidget {
  const PatiFavorilerScreen({super.key});

  @override
  State<PatiFavorilerScreen> createState() => _PatiFavorilerScreenState();
}

class _PatiFavorilerScreenState extends State<PatiFavorilerScreen> {
  static const String _guideFavoritesKey = 'favorite_guide_article_ids';
  static const String _funFavoritesKey = 'favorite_fun_article_ids';

  Set<String> _favoriteGuideIds = {};
  Set<String> _favoriteFunIds = {};
  bool _isLoading = true;

  List<_FavoriteContent> get _favoriteContents {
    final guideFavorites = mockGuideArticles
        .where((article) => _favoriteGuideIds.contains(article.id))
        .map(_FavoriteContent.guide);
    final funFavorites = mockFunArticles
        .where((article) => _favoriteFunIds.contains(article.id))
        .map(_FavoriteContent.fun);

    return [...guideFavorites, ...funFavorites];
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final guideIds = prefs.getStringList(_guideFavoritesKey) ?? [];
    final funIds = prefs.getStringList(_funFavoritesKey) ?? [];

    if (!mounted) return;
    setState(() {
      _favoriteGuideIds = guideIds.toSet();
      _favoriteFunIds = funIds.toSet();
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(_FavoriteContent content) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (content.isGuide) {
        _favoriteGuideIds = Set<String>.from(_favoriteGuideIds)
          ..remove(content.id);
      } else {
        _favoriteFunIds = Set<String>.from(_favoriteFunIds)..remove(content.id);
      }
    });

    if (content.isGuide) {
      await prefs.setStringList(_guideFavoritesKey, _favoriteGuideIds.toList());
    } else {
      await prefs.setStringList(_funFavoritesKey, _favoriteFunIds.toList());
    }
  }

  void _openDetail(_FavoriteContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (content.guideArticle != null) {
            return RehberDetailScreen(article: content.guideArticle!);
          }

          return PatiKeyfiDetailScreen(article: content.funArticle!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final favoriteContents = _favoriteContents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PatiSurfaceCard(
            padding: const EdgeInsets.all(20),
            radius: 24,
            color: Colors.white.withValues(alpha: 0.45),
            borderOpacity: 0,
            shadowOpacity: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PatiIconContainer(
                  icon: Icons.favorite_rounded,
                  startColor: colorScheme.primary.withValues(alpha: 0.58),
                  endColor: colorScheme.tertiary.withValues(alpha: 0.36),
                  overlayIcon: Icons.bookmark_rounded,
                  size: 68,
                  radius: 22,
                  iconSize: 31,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorilerim',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kaydettiğin Rehber ve Pati Keyfi içerikleri burada birlikte görünür.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.74),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (favoriteContents.isEmpty)
            const _FavoritesEmptyState()
          else
            ...favoriteContents.map(
              (content) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FavoriteContentCard(
                  content: content,
                  onTap: () => _openDetail(content),
                  onRemove: () => _removeFavorite(content),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoriteContent {
  const _FavoriteContent.guide(GuideArticle article)
      : guideArticle = article,
        funArticle = null;

  const _FavoriteContent.fun(FunArticle article)
      : guideArticle = null,
        funArticle = article;

  final GuideArticle? guideArticle;
  final FunArticle? funArticle;

  bool get isGuide => guideArticle != null;
  String get id => guideArticle?.id ?? funArticle!.id;
  String get title => guideArticle?.title ?? funArticle!.title;
  String get summary => guideArticle?.summary ?? funArticle!.summary;
  IconData get icon => guideArticle?.icon ?? funArticle!.icon;
  String get sectionLabel => isGuide ? 'Rehber' : 'Pati Keyfi';
}

class _FavoriteContentCard extends StatelessWidget {
  const _FavoriteContentCard({
    required this.content,
    required this.onTap,
    required this.onRemove,
  });

  final _FavoriteContent content;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tintColor =
        content.isGuide ? colorScheme.secondary : colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: PatiSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          radius: 28,
          color: Colors.white.withValues(alpha: 0.66),
          shadowOpacity: 0.05,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PatiIconContainer(
                icon: content.icon,
                startColor: colorScheme.primary.withValues(alpha: 0.58),
                endColor: colorScheme.secondary.withValues(alpha: 0.38),
                showOverlayDot: content.isGuide,
                overlayIcon:
                    content.isGuide ? null : Icons.favorite_outline_rounded,
                size: 68,
                radius: 22,
                iconSize: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PatiBadge(
                      label: content.sectionLabel,
                      tintColor: tintColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.summary,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.74),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  _RemoveFavoriteButton(
                    onPressed: onRemove,
                    activeColor: tintColor,
                  ),
                  const SizedBox(height: 8),
                  const PatiArrowChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveFavoriteButton extends StatelessWidget {
  const _RemoveFavoriteButton({
    required this.onPressed,
    required this.activeColor,
  });

  final VoidCallback onPressed;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'Favorilerden çıkar',
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.72),
          foregroundColor: activeColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(
              color: activeColor.withValues(alpha: 0.28),
            ),
          ),
        ),
        icon: const Icon(
          Icons.favorite_rounded,
          size: 19,
        ),
      ),
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PatiSurfaceCard(
      padding: const EdgeInsets.all(22),
      radius: 28,
      color: Colors.white.withValues(alpha: 0.58),
      shadowOpacity: 0.035,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz favorin yok',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rehber veya Pati Keyfi kartlarında kalbe dokunduğunda kaydettiğin içerikler burada toplanır.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
