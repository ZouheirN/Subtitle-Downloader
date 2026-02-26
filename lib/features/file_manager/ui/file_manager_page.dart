import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:subtitle_downloader/features/file_manager/ui/file_subtitle_select_dialog.dart';
import 'package:subtitle_downloader/main.dart';

class FileManagerPage extends StatelessWidget {
  final FileManagerController _fileManagerController = FileManagerController();

  FileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ControlBackButton(
      controller: _fileManagerController,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder<String>(
            valueListenable: _fileManagerController.titleNotifier,
            builder: (context, value, child) {
              final path = _fileManagerController.getCurrentPath;
              final showLeading = path != '' && path != '/storage/emulated/0';
              return AppBar(
                actions: [
                  IconButton(
                    onPressed: () async {
                      if (!await Permission.manageExternalStorage.isGranted) {
                        await Permission.manageExternalStorage.request();
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Permission already granted"),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.key_rounded),
                    tooltip: "Request Files Access Permission",
                  ),
                  IconButton(
                    onPressed: () => sort(context),
                    icon: const Icon(Icons.sort_rounded),
                    tooltip: "Sort",
                  ),
                  IconButton(
                    onPressed: () => selectStorage(context),
                    icon: const Icon(Icons.sd_storage_rounded),
                    tooltip: "Select Storage",
                  )
                ],
                title: Text(value),
                automaticallyImplyLeading: false,
                leading: showLeading
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () async {
                          await _fileManagerController.goToParentDirectory();
                        },
                      )
                    : null,
              );
            },
          ),
        ),
        body: FileManager(
          controller: _fileManagerController,
          builder: (context, snapshot) {
            final List<FileSystemEntity> entities = snapshot;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
              itemCount: entities.length,
              itemBuilder: (context, index) {
                FileSystemEntity entity = entities[index];
                return Card(
                  child: ListTile(
                    leading: FileManager.isFile(entity)
                        ? const Icon(Icons.insert_drive_file_outlined)
                        : const Icon(Icons.folder),
                    title: Text(
                      FileManager.basename(
                        entity,
                        showFileExtension: true,
                      ),
                    ),
                    subtitle: subtitle(entity),
                    onTap: () async {
                      if (FileManager.isDirectory(entity)) {
                        // open the folder
                        _fileManagerController.openDirectory(entity);
                      } else {
                        String fileName = entity.path.split('/').last;
                        List<String> nameParts = fileName.split('.');
                        nameParts.removeLast(); // Remove the file extension
                        fileName = nameParts.join('.');

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
            );
          },
        ),
      ),
    );
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;

            return Text(
              FileManager.formatBytes(size),
            );
          }
          return Text(
            "${snapshot.data!.modified}".substring(0, 10),
          );
        } else {
          return const Text("");
        }
      },
    );
  }

  Future<void> selectStorage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                              title: Text(
                                FileManager.basename(e),
                              ),
                              onTap: () {
                                _fileManagerController.openDirectory(e);
                                Navigator.pop(context);
                              },
                            ))
                        .toList()),
              );
            }
            return const Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<void> sort(BuildContext context) async {
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
                    _fileManagerController.sortBy(SortBy.name);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Size"),
                  onTap: () {
                    _fileManagerController.sortBy(SortBy.size);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Date"),
                  onTap: () {
                    _fileManagerController.sortBy(SortBy.date);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Type"),
                  onTap: () {
                    _fileManagerController.sortBy(SortBy.type);
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
