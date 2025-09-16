import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/media_provider.dart';
import '../../../data/models/media_model.dart';
import '../../../data/models/collection_model.dart';

class MediaDetailPage extends StatefulWidget {
  final Media media;

  const MediaDetailPage({super.key, required this.media});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late Media _currentMedia;
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Collection? _selectedCollection;

  @override
  void initState() {
    super.initState();
    _currentMedia = widget.media;
    _nameController.text = _currentMedia.name;
    _descriptionController.text = _currentMedia.description ?? '';

    // Load collections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().loadCollections();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset values if canceling edit
        _nameController.text = _currentMedia.name;
        _descriptionController.text = _currentMedia.description ?? '';
        _selectedCollection = null;
      }
    });
  }

  Future<void> _saveChanges() async {
    final mediaProvider = context.read<MediaProvider>();

    final updatedMedia = await mediaProvider.updateMedia(
      id: _currentMedia.id,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      collectionId: _selectedCollection?.id,
    );

    if (updatedMedia != null) {
      setState(() {
        _currentMedia = updatedMedia;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Media updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update media: ${mediaProvider.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMedia() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    final mediaProvider = context.read<MediaProvider>();
    final success = await mediaProvider.deleteMedia(_currentMedia.id);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Media deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete media: ${mediaProvider.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Media'),
            content: Text(
              'Are you sure you want to delete "${_currentMedia.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showCollectionSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Consumer<MediaProvider>(
          builder: (context, mediaProvider, child) {
            final collections = mediaProvider.collections;
            final isLoading = mediaProvider.isLoadingCollections;

            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (collections.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No collections found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount:
                            collections.length +
                            1, // +1 for "Remove from collection"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Option to remove from collection
                            return ListTile(
                              leading: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              title: Text('Remove from collection'),
                              subtitle: Text(
                                'This media will not belong to any collection',
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCollection = null;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }

                          final collection = collections[index - 1];
                          final isSelected =
                              collection.id == _currentMedia.collectionId;

                          return ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[600],
                            ),
                            title: Text(
                              collection.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : null,
                              ),
                            ),
                            subtitle: collection.description != null
                                ? Text(collection.description!)
                                : null,
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCollection = collection;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Media' : _currentMedia.name),
        backgroundColor: _getTypeColor(),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit),
              tooltip: 'Edit',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _deleteMedia();
                    break;
                  case 'collection':
                    _showCollectionSelector();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'collection',
                  child: Row(
                    children: [
                      Icon(Icons.folder, size: 20),
                      SizedBox(width: 8),
                      Text('Manage Collection'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: _toggleEdit,
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      body: Consumer<MediaProvider>(
        builder: (context, mediaProvider, child) {
          if (mediaProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(mediaProvider.errorMessage!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () => mediaProvider.clearError(),
                  ),
                ),
              );
            });
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Preview
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildMediaPreview(),
                  ),
                ),

                SizedBox(height: 24),

                // Media Information
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Name
                        _buildInfoField(
                          label: 'Name',
                          child: _isEditing
                              ? TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                )
                              : Text(
                                  _currentMedia.name,
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),

                        SizedBox(height: 16),

                        // Description
                        _buildInfoField(
                          label: 'Description',
                          child: _isEditing
                              ? TextField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Add a description...',
                                    isDense: true,
                                  ),
                                  maxLines: 3,
                                )
                              : Text(
                                  _currentMedia.description ?? 'No description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _currentMedia.description != null
                                        ? Colors.black
                                        : Colors.grey[500],
                                  ),
                                ),
                        ),

                        SizedBox(height: 16),

                        // Type and Size
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoField(
                                label: 'Type',
                                child: Row(
                                  children: [
                                    Icon(
                                      _getTypeIcon(),
                                      color: _getTypeColor(),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _currentMedia.type.name.toUpperCase(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoField(
                                label: 'Size',
                                child: Text(
                                  _currentMedia.formattedSize,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Collection
                        if (_isEditing)
                          _buildInfoField(
                            label: 'Collection',
                            child: GestureDetector(
                              onTap: _showCollectionSelector,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedCollection?.name ??
                                          (_currentMedia.collectionId != null
                                              ? 'Current collection'
                                              : 'Select collection'),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (_currentMedia.collectionId != null)
                          _buildInfoField(
                            label: 'Collection',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Part of collection',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 16),

                        // Dates
                        _buildInfoField(
                          label: 'Created',
                          child: Text(
                            _formatDateTime(_currentMedia.createdAt),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        SizedBox(height: 12),

                        _buildInfoField(
                          label: 'Updated',
                          child: Text(
                            _formatDateTime(_currentMedia.updatedAt),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_currentMedia.type == MediaType.image &&
        _currentMedia.fileUrl != null) {
      return Image.network(
        _currentMedia.fileUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _getTypeColor().withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(),
              size: 64,
              color: _getTypeColor().withOpacity(0.6),
            ),
            SizedBox(height: 16),
            Text(
              _currentMedia.type.name.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getTypeColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        child,
      ],
    );
  }

  Color _getTypeColor() {
    switch (_currentMedia.type) {
      case MediaType.image:
        return Colors.blue;
      case MediaType.video:
        return Colors.red;
      case MediaType.audio:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (_currentMedia.type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.video_library;
      case MediaType.audio:
        return Icons.audio_file;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
