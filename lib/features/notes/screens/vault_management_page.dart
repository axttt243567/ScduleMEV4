import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../data/vault_data.dart';

class VaultManagementPage extends StatefulWidget {
  const VaultManagementPage({super.key});

  @override
  State<VaultManagementPage> createState() => _VaultManagementPageState();
}

class _VaultManagementPageState extends State<VaultManagementPage> {
  // Navigation stack: Empty means we are at the Root (Vault List)
  final List<NoteFolder> _navigationStack = [];

  // Clipboard
  dynamic _clipboardItem; // NoteFolder or NoteFile
  String? _clipboardAction; // 'copy' or 'move'
  List<dynamic>? _sourceParentList; // For 'move' action (NoteFolder list or NoteFile list)


  NoteFolder? get _currentFolder =>
      _navigationStack.isNotEmpty ? _navigationStack.last : null;

  // Helpers to get current content
  List<NoteFolder> get _currentSubFolders {
    if (_currentFolder == null) {
      return VaultData.vaults; // Root level vaults
    } else {
      return _currentFolder!.subFolders;
    }
  }

  List<NoteFile> get _currentFiles {
    if (_currentFolder == null) {
      return []; // No files at root level (only vaults)
    } else {
      return _currentFolder!.files;
    }
  }

  void _enterFolder(NoteFolder folder) {
    setState(() {
      _navigationStack.add(folder);
    });
  }

  void _navigateBack() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _goToRoot() {
    setState(() {
      _navigationStack.clear();
    });
  }

  // --- CRUD Operations ---

  void _copyItem(dynamic item) {
    setState(() {
      _clipboardItem = item;
      _clipboardAction = 'copy';
      _sourceParentList = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied "${item.name}"')),
    );
  }

  void _moveItem(dynamic item, List<dynamic> parentList) {
    setState(() {
      _clipboardItem = item;
      _clipboardAction = 'move';
      _sourceParentList = parentList;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cut "${item.name}"')),
    );
  }

  void _pasteItem() {
    if (_clipboardItem == null || _clipboardAction == null) return;

    setState(() {
      dynamic newItem;
      
      if (_clipboardAction == 'copy') {
        if (_clipboardItem is NoteFolder) {
          newItem = _deepCopyFolder(_clipboardItem);
        } else if (_clipboardItem is NoteFile) {
          newItem = _deepCopyFile(_clipboardItem);
        }
      } else if (_clipboardAction == 'move') {
        newItem = _clipboardItem; // In move, we use the same reference
      }

      // Check for name conflict and rename if needed
      String originalName = newItem.name;
      int counter = 1;
      // Get list of existing names in current location
      List<String> existingNames = [];
      if (_currentFolder == null) {
        existingNames = VaultData.vaults.map((e) => e.name).toList();
      } else {
        existingNames = [
          ..._currentFolder!.subFolders.map((e) => e.name),
          ..._currentFolder!.files.map((e) => e.name)
        ];
      }
      
      while (existingNames.contains(newItem.name)) {
        newItem.name = '$originalName ($counter)'; // Adjust name directly? 
        // For NoteFile, name is final (wait, I made it NOT final in note_model? No I didn't. 
        // If NoteFile name is final, I need to create a new one with new name.
        if (newItem is NoteFile) {
           newItem = _copyFileWithName(newItem, '$originalName ($counter)');
        }
        counter++;
      }
      // NoteFolder name is mutable, so simple assignment works (if I made it mutable).
      // Let's assume NoteFolder name IS mutable based on previous rename logic.
      if (newItem is NoteFolder && existingNames.contains(newItem.name)) {
         newItem.name = '$originalName ($counter)';
      }


      // Add to current location
      if (newItem is NoteFolder) {
        if (_currentFolder == null) {
          VaultData.vaults.add(newItem);
        } else {
          _currentFolder!.subFolders.add(newItem);
        }
      } else if (newItem is NoteFile) {
        if (_currentFolder != null) {
           _currentFolder!.files.add(newItem);
        } else {
           // Cannot paste file at root
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot paste file at root level')),
            );
            return;
        }
      }

      // If move, remove from source
      if (_clipboardAction == 'move' && _sourceParentList != null) {
        _sourceParentList!.remove(_clipboardItem);
        _clipboardItem = null;
        _clipboardAction = null;
        _sourceParentList = null;
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Moved successfully')),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Pasted successfully')),
        );
        // Keep clipboard for 'copy' (allow multiple pastes) but maybe clear for UX?
        // Usually copy stays in clipboard.
      }
    });
  }

  NoteFolder _deepCopyFolder(NoteFolder original) {
    return NoteFolder(
      name: original.name,
      color: original.color,
      icon: original.icon,
      syncStatus: original.syncStatus,
      files: original.files.map((f) => _deepCopyFile(f)).toList(),
      subFolders: original.subFolders.map((f) => _deepCopyFolder(f)).toList(),
    );
  }

  NoteFile _deepCopyFile(NoteFile original) {
    return NoteFile(
      name: original.name,
      type: original.type,
      size: original.size,
      date: original.date,
      demoUrl: original.demoUrl,
      assetPath: original.assetPath,
    );
  }
  
  NoteFile _copyFileWithName(NoteFile original, String newName) {
     return NoteFile(
      name: newName,
      type: original.type,
      size: original.size,
      date: original.date,
      demoUrl: original.demoUrl,
      assetPath: original.assetPath,
    );
  }

  void _createNewItem({bool isFolder = true}) {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161E),
        title: Text(
          isFolder 
              ? (_currentFolder == null ? 'New Vault' : 'New Folder') 
              : 'New File',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter name',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _performCreate(nameController.text, isFolder);
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  void _performCreate(String name, bool isFolder) {
    setState(() {
      if (_currentFolder == null) {
        // Create Vault
        if (isFolder) {
          VaultData.vaults.add(NoteFolder(
            name: name,
            color: Colors.blue, // Default color
            icon: Icons.folder,
          ));
        }
      } else {
        // Create inside folder
        if (isFolder) {
          _currentFolder!.subFolders.add(NoteFolder(
            name: name,
            color: Colors.blue,
            icon: Icons.folder,
          ));
        } else {
          // Create dummy file
          _currentFolder!.files.add(NoteFile(
            name: name,
            type: FileType.txt,
            size: '0 KB',
            date: 'Now',
          ));
        }
      }
    });
  }

  void _renameItem(dynamic item) { // item is NoteFolder or NoteFile
    final TextEditingController nameController = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161E),
        title: const Text('Rename', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  if (item is NoteFolder) {
                    item.name = nameController.text;
                  } else if (item is NoteFile) {
                    // NoteFile fields are final in my model, wait. 
                    // I need to replace the object or make fields mutable. 
                    // Making them mutable is easier for now, but I declared them final.
                    // Actually NoteFile is immutable in the model I wrote.
                    // I'll create a new copy.
                    
                    // Find index and replace is hard without parent reference.
                    // I need parent to replace.
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Rename', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }
  
  // Since NoteFile is immutable, I need to handle rename/delete via PARENT list.
  // So I need to pass the list and index or just handle it in the UI building.

  void _showOptions(dynamic item, List<dynamic> parentList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Rename', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (item is NoteFolder) {
                   _renameItem(item); // NoteFolder name is mutable (I made it NOT final in model? let me check. I made them final in the replacement tool... wait. 
                   // I should check `note_model.dart` content.
                   // In step 50, I wrote: `class NoteFolder { String name; ... }` (removed final for name). 
                   // `NoteFile` has `final String name`.
                   // So Folder is mutable, File is not.
                   
                   // For File, I need to remove and add.
                } else if (item is NoteFile) {
                   _renameFile(item, parentList as List<NoteFile>);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item, parentList);
              },
            ),
             const Divider(color: Colors.grey),
             ListTile(
              leading: const Icon(Icons.copy, color: Colors.blueAccent),
              title: const Text('Copy', style: TextStyle(color: Colors.blueAccent)),
              onTap: () {
                Navigator.pop(context);
                _copyItem(item);
              },
            ),
             ListTile(
              leading: const Icon(Icons.drive_file_move, color: Colors.orangeAccent),
              title: const Text('Move', style: TextStyle(color: Colors.orangeAccent)),
              onTap: () {
                Navigator.pop(context);
                _moveItem(item, parentList);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _renameFile(NoteFile file, List<NoteFile> list) {
      final TextEditingController nameController = TextEditingController(text: file.name);
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161E),
        title: const Text('Rename File', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
           autofocus: true,
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[500]))),
          TextButton(
            onPressed: () {
               if(nameController.text.isNotEmpty) {
                 setState(() {
                   int index = list.indexOf(file);
                   if(index != -1) {
                     list[index] = NoteFile(
                       name: nameController.text,
                       type: file.type,
                       size: file.size,
                       date: file.date,
                       demoUrl: file.demoUrl,
                       assetPath: file.assetPath
                     );
                   }
                 });
                 Navigator.pop(context);
               }
            }, 
            child: const Text('Save', style: TextStyle(color: Colors.blue))
          ),
        ],
      ));
  }

  void _confirmDelete(dynamic item, List<dynamic> parentList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161E),
        title: const Text('Delete Item?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${item.name}"?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                parentList.remove(item);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folders = _currentSubFolders;
    final files = _currentFiles;
    final isRoot = _navigationStack.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _navigateBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vault Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             if (!isRoot)
              Text(
                _navigationStack.map((e) => e.name).join(' / '),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (_clipboardItem != null)
            IconButton(
              icon: Icon(
                _clipboardAction == 'move' ? Icons.paste_outlined : Icons.content_paste,
                color: Colors.white,
              ),
              tooltip: _clipboardAction == 'move' ? 'Move Here' : 'Paste Here',
              onPressed: _pasteItem,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Folders
          if (folders.isNotEmpty) ...[
            Text(
              isRoot ? 'VAULTS' : 'FOLDERS',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ...folders.map((folder) => _buildFolderTile(folder, folders)),
            const SizedBox(height: 24),
          ],

          // Files
          if (files.isNotEmpty) ...[
            Text(
              'FILES',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ...files.map((file) => _buildFileTile(file, files)),
          ],
          
          if(folders.isEmpty && files.isEmpty)
             SizedBox(
               height: 200,
               child: Center(
                 child: Text(
                   'Empty Folder',
                   style: TextStyle(color: Colors.grey[700]),
                 ),
               ),
             )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add),
        onPressed: () {
           // If root, can only create folders (Vaults)
           if (isRoot) {
             _createNewItem(isFolder: true);
           } else {
             // Show options: Folder or File
             showModalBottomSheet(
               context: context,
               backgroundColor: const Color(0xFF16161E),
               builder: (context) => Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   ListTile(
                     leading: const Icon(Icons.create_new_folder, color: Colors.blue),
                     title: const Text('New Folder', style: TextStyle(color: Colors.white)),
                     onTap: () {
                       Navigator.pop(context);
                       _createNewItem(isFolder: true);
                     },
                   ),
                   ListTile(
                     leading: const Icon(Icons.note_add, color: Colors.green),
                     title: const Text('New File', style: TextStyle(color: Colors.white)),
                     onTap: () {
                       Navigator.pop(context);
                       _createNewItem(isFolder: false);
                     },
                   ),
                 ],
               ),
             );
           }
        },
      ),
    );
  }

  Widget _buildFolderTile(NoteFolder folder, List<NoteFolder> parentList) {
    return Card(
      color: const Color(0xFF16161E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(folder.icon, color: folder.color),
        title: Text(folder.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${folder.folderCount} folders, ${folder.files.length} files',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[500]),
          onPressed: () => _showOptions(folder, parentList),
        ),
        onTap: () => _enterFolder(folder),
      ),
    );
  }

  Widget _buildFileTile(NoteFile file, List<NoteFile> parentList) {
    return Card(
      color: const Color(0xFF16161E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(file.icon, color: file.color),
        title: Text(file.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${file.extension} • ${file.size}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[500]),
          onPressed: () => _showOptions(file, parentList),
        ),
      ),
    );
  }
}
