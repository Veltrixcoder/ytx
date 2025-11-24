import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ytx/providers/navigation_provider.dart';
import 'package:ytx/providers/explore_provider.dart';
import 'package:ytx/screens/search_screen.dart';
import 'package:ytx/widgets/result_tile.dart';
import 'package:ytx/screens/library_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildExploreTab(context, ref),
          const SearchScreen(),
          const LibraryScreen(),
          // Placeholder for Settings (index 3) if we want it in the stack, 
          // but we navigate to it separately in MainLayout.
          // However, IndexedStack needs a child for index 3 if selectedIndex is 3.
          // Since we push SettingsScreen, selectedIndex might stay 3 but we are on a new route.
          // Or we can just put a SizedBox here.
          const SizedBox.shrink(), 
        ],
      ),
    );
  }

  Widget _buildExploreTab(BuildContext context, WidgetRef ref) {
    final exploreContent = ref.watch(exploreContentProvider);
    
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Explore',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.cast, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: exploreContent.when(
              data: (results) {
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'No content available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 160),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return ResultTile(result: results[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
