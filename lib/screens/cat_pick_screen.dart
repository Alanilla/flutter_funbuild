import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../components/card_bar.dart';
import '../services/cataas_api.dart';

class TinderSwipeScreen extends StatefulWidget {
  const TinderSwipeScreen({super.key});

  @override
  State<TinderSwipeScreen> createState() => _TinderSwipeScreenState();
}

class _TinderSwipeScreenState extends State<TinderSwipeScreen> {
  final CardSwiperController controller = CardSwiperController();

  List<String> catImages = [];
  final List<String> liked = [];
  final List<String> passed = [];

  bool loading = true;
  String? error;
  bool finished = false;

  int catCount = 12; //default cat count

  @override
  void initState() {
    super.initState();
    // _loadCats();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _askForCountAndLoad();
    });
  }

   Future<void> _askForCountAndLoad() async {
    final result = await _showCountDialog(initial: catCount);
    if (result == null) return; // user cancelled; stay idle
    setState(() {
      catCount = result;
      loading = true;
      error = null;
      finished = false;
      liked.clear();
      passed.clear();
      catImages.clear();
    });
    await _loadCats();
  }

  Future<void> _loadCats() async {
    try {
      final imgs = await CataasApi.fetchCatImages(count: catCount);
      setState(() {
        catImages = imgs;
        loading = false;
        error = null;
        liked.clear();
        passed.clear();
        finished = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load cats: $e';
        finished = true;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleSwipe(int previousIndex, CardSwiperDirection? direction) {
    if (previousIndex < 0 || previousIndex >= catImages.length) return;
    final url = catImages[previousIndex];

    setState(() {
      if (direction == CardSwiperDirection.right ||
          direction == CardSwiperDirection.top) {
        liked.add(url);
      } else if (direction == CardSwiperDirection.left ||
          direction == CardSwiperDirection.bottom) {
        passed.add(url);
      }

      // If all cards handled, mark finished
      if (liked.length + passed.length >= catImages.length) {
        finished = true;
      }
    });
  }

  void _showSummarySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Summary', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TabBar(
                tabs: [
                  Tab(text: 'Liked (${liked.length})'),
                  Tab(text: 'Passed (${passed.length})'),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  children: [
                    _ImageGrid(items: liked),
                    _ImageGrid(items: passed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Future<int?> _showCountDialog({required int initial}) async {
    final txt = TextEditingController(text: initial.toString());
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How many cats?'),
        content: TextField(
          controller: txt,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter a number (1–200)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(txt.text.trim());
              if (val != null && val > 0 && val <= 200) {
                Navigator.pop(ctx, val);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final footer = Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        'Liked: ${liked.length}   •   Passed: ${passed.length}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Picker'),
        actions: [
          IconButton(
            tooltip: 'Set number of cats',
            icon: const Icon(Icons.settings),
            onPressed: _askForCountAndLoad,
          ),
          IconButton(
            tooltip: 'Refresh cats',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => loading = true);
              await _loadCats();
            },
          ),
          IconButton(
            tooltip: 'Summary',
            icon: const Icon(Icons.list_alt),
            onPressed: (liked.isEmpty && passed.isEmpty)
                ? null
                : _showSummarySheet,
          ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : (error != null)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          setState(() => loading = true);
                          _loadCats();
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            : finished
            ? _EndScreen(
                likedCount: liked.length,
                passedCount: passed.length,
                onRefresh: () {
                  setState(() => loading = true);
                  _loadCats();
                },
                onSummary: _showSummarySheet,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 500,
                    width: 350,
                    child: CardSwiper(
                      controller: controller,
                      cardsCount: catImages.length,
                      isLoop: false, // stop looping
                      numberOfCardsDisplayed: 2,
                      scale: 0.9,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      cardBuilder: (context, index, x, y) {
                        final imageUrl = catImages[index];
                        final swipeProgress = x.toDouble();

                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stack) =>
                                    Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                    ),
                              ),
                              // LIKE / NOPE badges (based on horizontal drag)
                              if (swipeProgress.abs() > 50)
                                Positioned(
                                  top: 20,
                                  left: swipeProgress < 0 ? 20 : null,
                                  right: swipeProgress > 0 ? 20 : null,
                                  child: Transform.rotate(
                                    angle: swipeProgress < 0 ? -0.2 : 0.2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: swipeProgress > 0
                                              ? Colors.green
                                              : Colors.red,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.25),
                                      ),
                                      child: Text(
                                        swipeProgress > 0 ? 'LIKE' : 'NOPE',
                                        style: TextStyle(
                                          color: swipeProgress > 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      onSwipe: (previousIndex, currentIndex, direction) {
                        _handleSwipe(previousIndex, direction);
                        return true;
                      },
                      allowedSwipeDirection:
                          const AllowedSwipeDirection.symmetric(
                            horizontal: true,
                            vertical: true,
                          ),
                      // numberOfCardsDisplayed: 3,
                      // scale: 0.9,
                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: 16,
                      //   vertical: 8,
                      // ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CardBar(
                    onPass: () => controller.swipe(CardSwiperDirection.left),
                    onSuperLike: () =>
                        controller.swipe(CardSwiperDirection.top),
                    onLike: () => controller.swipe(CardSwiperDirection.right),
                  ),
                  const SizedBox(height: 8),
                  footer,
                ],
              ),
      ),
    );
  }
}

class _EndScreen extends StatelessWidget {
  final int likedCount;
  final int passedCount;
  final VoidCallback onRefresh;
  final VoidCallback onSummary;

  const _EndScreen({
    required this.likedCount,
    required this.passedCount,
    required this.onRefresh,
    required this.onSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64),
            const SizedBox(height: 12),
            Text('All done!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Liked: $likedCount   •   Passed: $passedCount'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh cats'),
                ),
                OutlinedButton.icon(
                  onPressed: onSummary,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Summary'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<String> items;
  const _ImageGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Nothing here yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.only(top: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          items[i],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFFE0E0E0),
            child: Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
