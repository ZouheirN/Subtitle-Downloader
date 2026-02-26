import 'dart:math';

import 'package:flutter/material.dart';
import 'package:storax/storax.dart';
import 'package:subtitle_downloader/features/file_manager/ui/file_subtitle_select_dialog.dart';

enum _SortBy { name, size, date, type }

class _NavEntry {
  final String target;
  final bool isSaf;
  final String title;

  const _NavEntry({
    required this.target,
    required this.isSaf,
    required this.title,
  });
}

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  /// Notifier that holds the back callback when the file manager has
  /// navigation history, or null when it's at the root.
  static final backHandler = ValueNotifier<VoidCallback?>(null);

  @override
  State<FileManagerPage> createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage> {
  final _storax = Storax();
  final List<_NavEntry> _pathStack = [];
  List<StoraxEntry> _entries = [];
  bool _loading = false;
  _SortBy _sortBy = _SortBy.name;
  int _rootCount = 0;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermission());
  }

  Future<void> _ensurePermission() async {
    final granted = await _storax.hasAllFilesAccess();
    if (!mounted) return;
    if (granted) {
      setState(() => _hasPermission = true);
      _showStorageRoots();
    } else {
      setState(() => _hasPermission = false);
      await _storax.requestAllFilesAccess();
      if (!mounted) return;
      final now = await _storax.hasAllFilesAccess();
      if (!mounted) return;
      setState(() => _hasPermission = now);
      if (now) _showStorageRoots();
    }
  }

  Future<void> _loadDirectory() async {
    if (_pathStack.isEmpty) return;
    setState(() => _loading = true);

    final nav = _pathStack.last;
    final data = await _storax.listDirectory(
      target: nav.target,
      isSaf: nav.isSaf,
    );
    if (!mounted) return;
    setState(() {
      _entries = _sortEntries(data);
      _loading = false;
    });
  }

  List<StoraxEntry> _sortEntries(List<StoraxEntry> entries) {
    final dirs = entries.where((e) => e.isDirectory).toList();
    final files = entries.where((e) => !e.isDirectory).toList();

    int compare(StoraxEntry a, StoraxEntry b) {
      switch (_sortBy) {
        case _SortBy.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _SortBy.size:
          return a.size.compareTo(b.size);
        case _SortBy.date:
          return a.lastModified.compareTo(b.lastModified);
        case _SortBy.type:
          final extA = a.name.contains('.') ? a.name.split('.').last : '';
          final extB = b.name.contains('.') ? b.name.split('.').last : '';
          return extA.compareTo(extB);
      }
    }

    dirs.sort(compare);
    files.sort(compare);
    return [...dirs, ...files];
  }

  bool _canGoBack() => _pathStack.length > 1;

  void _updateBackHandler() {
    FileManagerPage.backHandler.value = _canGoBack() ? _goBack : null;
  }

  void _goBack() {
    if (_canGoBack()) {
      setState(() => _pathStack.removeLast());
      _updateBackHandler();
      _loadDirectory();
    }
  }

  @override
  void dispose() {
    FileManagerPage.backHandler.value = null;
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final val = bytes / pow(1024, i);
    return '${val.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  Future<void> _requestPermission() async {
    await _storax.requestAllFilesAccess();
    if (!mounted) return;
    final granted = await _storax.hasAllFilesAccess();
    if (!mounted) return;
    setState(() => _hasPermission = granted);
    if (granted) _showStorageRoots();
  }

  void _selectVolume(StoraxVolume v) {
    final target = v.isSaf ? v.uri! : v.path!;
    setState(() {
      _pathStack.clear();
      _pathStack.add(_NavEntry(
        target: target,
        isSaf: v.isSaf,
        title: v.name,
      ));
    });
    _updateBackHandler();
    _loadDirectory();
  }

  Future<void> _showStorageRoots() async {
    if (!mounted) return;

    final allRoots = await _storax.getAllRoots();
    if (!mounted) return;

    final roots =
        allRoots.where((v) => (v.isSaf ? v.uri : v.path) != null).toList();

    setState(() => _rootCount = roots.length);

    if (roots.length == 1) {
      _selectVolume(roots.first);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...roots.map(
                (v) => ListTile(
                  leading: Icon(v.isSaf ? Icons.lock : Icons.storage),
                  title: Text(v.name),
                  subtitle: Text(v.isSaf ? 'SAF folder' : (v.path ?? '')),
                  onTap: () {
                    _selectVolume(v);
                    Navigator.pop(context);
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSortDialog() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Name"),
                onTap: () {
                  setState(() {
                    _sortBy = _SortBy.name;
                    _entries = _sortEntries(_entries);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Size"),
                onTap: () {
                  setState(() {
                    _sortBy = _SortBy.size;
                    _entries = _sortEntries(_entries);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Date"),
                onTap: () {
                  setState(() {
                    _sortBy = _SortBy.date;
                    _entries = _sortEntries(_entries);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Type"),
                onTap: () {
                  setState(() {
                    _sortBy = _SortBy.type;
                    _entries = _sortEntries(_entries);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        _pathStack.isEmpty ? 'File Manager' : _pathStack.last.title;
    final showLeading = _canGoBack();

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: false,
          leading: showLeading
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goBack,
                )
              : null,
          actions: [
            if (!_hasPermission)
              IconButton(
                onPressed: _requestPermission,
                icon: const Icon(Icons.key_rounded),
                tooltip: "Request Files Access Permission",
              ),
            IconButton(
              onPressed: _showSortDialog,
              icon: const Icon(Icons.sort_rounded),
              tooltip: "Sort",
            ),
            if (_rootCount > 1)
              IconButton(
                onPressed: _showStorageRoots,
                icon: const Icon(Icons.sd_storage_rounded),
                tooltip: "Select Storage",
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _pathStack.isEmpty
                ? const Center(child: Text('Select a storage root'))
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Card(
                        child: ListTile(
                          leading: entry.isDirectory
                              ? const Icon(Icons.folder)
                              : const Icon(Icons.insert_drive_file_outlined),
                          title: Text(entry.name),
                          subtitle: _buildEntrySubtitle(entry),
                          onTap: () {
                            if (entry.isDirectory) {
                              final target =
                                  entry.isSaf ? entry.uri : entry.path;
                              if (target == null) return;
                              setState(() {
                                _pathStack.add(_NavEntry(
                                  target: target,
                                  isSaf: entry.isSaf,
                                  title: entry.name,
                                ));
                              });
                              _updateBackHandler();
                              _loadDirectory();
                            } else {
                              final fileName =
                                  _fileNameWithoutExtension(entry.name);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return FileSubtitleSelectDialog(
                                    fileName: fileName,
                                  );
                                },
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
    );
  }

  Widget _buildEntrySubtitle(StoraxEntry entry) {
    if (!entry.isDirectory) {
      return Text(_formatBytes(entry.size));
    }
    final dt = DateTime.fromMillisecondsSinceEpoch(entry.lastModified);
    return Text(dt.toString().substring(0, 10));
  }

  String _fileNameWithoutExtension(String name) {
    final parts = name.split('.');
    if (parts.length > 1) {
      parts.removeLast();
    }
    return parts.join('.');
  }
}
