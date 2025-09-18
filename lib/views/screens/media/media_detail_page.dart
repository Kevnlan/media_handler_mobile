// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../data/models/media_model.dart';

class MediaDetailPage extends StatefulWidget {
  final Media media;

  const MediaDetailPage({super.key, required this.media});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late Media _currentMedia;

  @override
  void initState() {
    super.initState();
    _currentMedia = widget.media;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentMedia.name),
        backgroundColor: _getTypeColor(),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                      child: Text(
                        _currentMedia.name,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Description
                    _buildInfoField(
                      label: 'Description',
                      child: Text(
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

                    // Collection (if part of one)
                    if (_currentMedia.collectionId != null)
                      _buildInfoField(
                        label: 'Collection',
                        child: Row(
                          children: [
                            Icon(Icons.folder, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Part of collection',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                    if (_currentMedia.collectionId != null)
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

                    // File URL (if available)
                    if (_currentMedia.fileUrl != null) ...[
                      SizedBox(height: 16),
                      _buildInfoField(
                        label: 'File URL',
                        child: GestureDetector(
                          onTap: () {
                            // Optional: Add functionality to copy URL to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('URL: ${_currentMedia.fileUrl}'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.link, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'View URL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_currentMedia.type == MediaType.image &&
        _currentMedia.fileUrl != null) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(),
        child: Stack(
          children: [
            Hero(
              tag: 'media_${_currentMedia.id}',
              child: Image.network(
                _currentMedia.fileUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
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
              ),
            ),
            // Subtle hint that image is clickable
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.fullscreen, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
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
            if (_currentMedia.type == MediaType.audio)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Audio file',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            if (_currentMedia.type == MediaType.video)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Video file',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Show full-screen image with zoom capabilities
  void _showFullScreenImage() {
    if (_currentMedia.fileUrl == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imageUrl: _currentMedia.fileUrl!,
          heroTag: 'media_${_currentMedia.id}',
          title: _currentMedia.name,
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

/// Full-screen image viewer with zoom and pan capabilities
class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final String title;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.heroTag,
    required this.title,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  bool _showAppBar = true;

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black54,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                widget.title,
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    // Add share functionality if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Share functionality can be added here'),
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading image...',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Could not load image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please check your internet connection',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
