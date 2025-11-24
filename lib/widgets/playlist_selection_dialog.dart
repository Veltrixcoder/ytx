import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ytx/models/ytify_result.dart';
import 'package:ytx/services/storage_service.dart';
import 'package:ytx/widgets/glass_snackbar.dart';

class PlaylistSelectionDialog extends ConsumerStatefulWidget {
  final YtifyResult song;

  const PlaylistSelectionDialog({super.key, required this.song});

  @override
  ConsumerState<PlaylistSelectionDialog> createState() => _PlaylistSelectionDialogState();
}

class _PlaylistSelectionDialogState extends ConsumerState<PlaylistSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final playlists = storage.getPlaylistNames();

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Add to Playlist', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: playlists.isEmpty
            ? const Text('No playlists created yet.', style: TextStyle(color: Colors.grey))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final name = playlists[index];
                  return ListTile(
                    leading: const Icon(Icons.playlist_play, color: Colors.white),
                    title: Text(name, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      storage.addToPlaylist(name, widget.song);
                      Navigator.pop(context);
                      showGlassSnackBar(context, 'Added to $name');
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _showCreatePlaylistDialog(context, storage);
          },
          child: const Text('New Playlist'),
        ),
      ],
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
                // Automatically add the song to the new playlist
                storage.addToPlaylist(controller.text, widget.song);
                Navigator.pop(context);
                showGlassSnackBar(context, 'Added to ${controller.text}');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
