import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({super.key, required this.id});
  final String id;
  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  @override
  void initState() {
    super.initState();
    BookmarkService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: BookmarkService.instance,
    builder: (context, _) {
      final saved = BookmarkService.instance.contains(widget.id);
      return IconButton(
        key: ValueKey('bookmark_${widget.id}'),
        tooltip: saved ? 'Убрать из закладок' : 'В закладки',
        isSelected: saved,
        icon: const Icon(Icons.bookmark_border_rounded),
        selectedIcon: const Icon(Icons.bookmark_rounded),
        onPressed: BookmarkService.instance.busy
            ? null
            : () async {
                try {
                  await BookmarkService.instance.toggle(widget.id);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Не удалось сохранить закладку. Попробуй ещё раз.',
                        ),
                      ),
                    );
                  }
                }
              },
      );
    },
  );
}
