import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ytx/models/ytify_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ytx/providers/player_provider.dart';
import 'package:ytx/widgets/playlist_selection_dialog.dart';
import 'package:ytx/widgets/glass_snackbar.dart';
import 'package:ytx/services/storage_service.dart';

class ResultTile extends ConsumerWidget {
  final YtifyResult result;

  const ResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine aspect ratio based on result type
    // Songs: 1:1 (square)
    // Videos: 16:9
    // Others: Default to 16:9 or 1:1 depending on preference, usually 1:1 for artists/playlists
    
    double width = 56; // Default height is 56, so width depends on ratio
    double height = 56;
    BoxFit fit = BoxFit.cover;

    if (result.resultType == 'video') {
      width = 100; // 16:9 approx (56 * 1.77 = 99.12)
    } else {
      width = 56; // 1:1
    }

    String imageUrl = '';
    if (result.thumbnails.isNotEmpty) {
      // Use the last thumbnail (usually highest quality) or first if only one
      imageUrl = result.thumbnails.last.url;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: fit,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(color: Colors.black, width: width, height: height),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  width: width,
                  height: height,
                  child: const Icon(Icons.error),
                ),
              )
            : Container(
                color: Colors.grey[900],
                width: width,
                height: height,
                child: const Icon(Icons.music_note),
              ),
      ),
      title: Text(
        result.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        () {
          String subtitle = '';
          if (result.artists != null && result.artists!.isNotEmpty) {
            subtitle += result.artists!.map((a) => a.name).join(', ');
          } else if (result.resultType == 'artist') {
            return 'Artist';
          } else if (result.resultType == 'playlist') {
            return 'Playlist';
          }

          if (result.duration != null) {
            if (subtitle.isNotEmpty) subtitle += ' • ';
            subtitle += result.duration!;
          }
          
          if (result.views != null) {
             if (subtitle.isNotEmpty) subtitle += ' • ';
             subtitle += '${result.views} views';
          }
          
          return subtitle;
        }(),
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      onTap: () {
        if (result.videoId != null) {
          ref.read(audioHandlerProvider).playVideo(result);
        }
      },

      // We need to wrap the PopupMenuButton with a Consumer to access storage
      trailing: Consumer(
        builder: (context, ref, _) {
          final storage = ref.watch(storageServiceProvider);
          return ValueListenableBuilder(
            valueListenable: storage.favoritesListenable,
            builder: (context, box, _) {
              final isFav = storage.isFavorite(result.videoId!);
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF1E1E1E),
                onSelected: (value) {
                  if (value == 'queue') {
                    ref.read(audioHandlerProvider).addToQueue(result);
                    showGlassSnackBar(context, 'Added to queue');
                  } else if (value == 'playlist') {
                    showDialog(
                      context: context,
                      builder: (context) => PlaylistSelectionDialog(song: result),
                    );
                  } else if (value == 'favorite') {
                    storage.toggleFavorite(result);
                    showGlassSnackBar(context, isFav ? 'Removed from favorites' : 'Added to favorites');
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'queue',
                    child: Row(
                      children: [
                        Icon(Icons.queue_music, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Add to queue', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'playlist',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Add to playlist', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'favorite',
                    child: Row(
                      children: [
                        Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(isFav ? 'Remove from favorites' : 'Add to favorites', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
