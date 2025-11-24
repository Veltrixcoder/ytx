import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ytx/services/storage_service.dart';
import 'package:ytx/screens/playlist_details_screen.dart';
import 'package:ytx/providers/player_provider.dart';
import 'package:ytx/models/ytify_result.dart';
import 'package:ytx/providers/download_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Favorites Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full favorites
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<Box>(
                valueListenable: storage.favoritesListenable,
                builder: (context, box, _) {
                  final favorites = storage.getFavorites();
                  if (favorites.isEmpty) {
                    return const Text('No favorites yet', style: TextStyle(color: Colors.grey));
                  }
                  return SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final item = favorites[index];
                        return GestureDetector(
                          onTap: () {
                            ref.read(audioHandlerProvider).playVideo(item);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.thumbnails.isNotEmpty ? item.thumbnails.last.url : '',
                                    height: 110,
                                    fit: BoxFit.fitHeight,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: Colors.grey[800], width: 110, height: 110),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),

              // Downloads Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Downloads',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full downloads
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<Box>(
                valueListenable: storage.downloadsListenable,
                builder: (context, box, _) {
                  final completedDownloads = storage.getDownloads();
                  final downloadState = ref.watch(downloadProvider);
                  final activeDownloads = downloadState.activeDownloads;
                  
                  if (completedDownloads.isEmpty && activeDownloads.isEmpty) {
                    return const Text('No downloads yet', style: TextStyle(color: Colors.grey));
                  }

                  return SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: activeDownloads.length + completedDownloads.length,
                      itemBuilder: (context, index) {
                        // Show active downloads first
                        if (index < activeDownloads.length) {
                          final videoId = activeDownloads.keys.elementAt(index);
                          final item = activeDownloads[videoId]!;
                          final progress = downloadState.progressMap[videoId] ?? 0.0;
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.5), 
                                          BlendMode.darken
                                        ),
                                        child: Image.network(
                                          item.thumbnails.isNotEmpty ? item.thumbnails.last.url : '',
                                          height: 110,
                                          fit: BoxFit.fitHeight,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(color: Colors.grey[800], width: 110, height: 110),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          color: Colors.white,
                                          strokeWidth: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        // Show completed downloads
                        final itemData = completedDownloads[index - activeDownloads.length];
                        final item = YtifyResult.fromJson(Map<String, dynamic>.from(itemData['result']));
                        return GestureDetector(
                          onTap: () {
                            ref.read(audioHandlerProvider).playVideo(item);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.thumbnails.isNotEmpty ? item.thumbnails.last.url : '',
                                    height: 110,
                                    fit: BoxFit.fitHeight,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: Colors.grey[800], width: 110, height: 110),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),

              // History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full history
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<Box>(
                valueListenable: storage.historyListenable,
                builder: (context, box, _) {
                  final history = storage.getHistory();
                  if (history.isEmpty) {
                    return const Text('No history yet', style: TextStyle(color: Colors.grey));
                  }
                  return SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.thumbnails.isNotEmpty ? item.thumbnails.last.url : '',
                                  height: 110,
                                  fit: BoxFit.fitHeight,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[800], width: 110, height: 110),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
                
              const SizedBox(height: 32),
              
              // Playlists Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      _showCreatePlaylistDialog(context, storage);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<Box>(
                valueListenable: storage.playlistsListenable,
                builder: (context, box, _) {
                  final playlists = storage.getPlaylistNames();
                  if (playlists.isEmpty) {
                    return const Text('No playlists created', style: TextStyle(color: Colors.grey));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final name = playlists[index];
                      final songs = storage.getPlaylistSongs(name);
                      return ListTile(
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.playlist_play, color: Colors.white),
                        ),
                        title: Text(name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${songs.length} songs', style: TextStyle(color: Colors.grey[400])),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistDetailsScreen(playlistName: name),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, StorageService storage) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Create Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                storage.createPlaylist(controller.text);
                setState(() {}); // Refresh UI
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
