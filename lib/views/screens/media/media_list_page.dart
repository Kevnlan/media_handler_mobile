import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/media_provider.dart';
import '../../../data/models/media_model.dart';
import '../../../data/models/pagination_model.dart';
import 'media_detail_page.dart';

class MediaListPage extends StatefulWidget {
  final MediaType mediaType;
  final String title;

  const MediaListPage({
    super.key,
    required this.mediaType,
    required this.title,
  });

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  final ScrollController _scrollController = ScrollController();
  MediaFilters _currentFilters = MediaFilters();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilters = MediaFilters(type: widget.mediaType, isDeleted: false);
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaProvider>().loadMediaByType(
        widget.mediaType,
        refresh: true,
        filters: _currentFilters,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more data when user scrolls near the bottom
      context.read<MediaProvider>().loadMediaByType(
        widget.mediaType,
        filters: _currentFilters,
      );
    }
  }

  void _applyFilters() {
    final search = _searchController.text.trim();
    _currentFilters = MediaFilters(
      type: widget.mediaType,
      isDeleted: false,
      search: search.isNotEmpty ? search : null,
    );

    context.read<MediaProvider>().loadMediaByType(
      widget.mediaType,
      refresh: true,
      filters: _currentFilters,
    );
  }

  void _refreshData() {
    context.read<MediaProvider>().loadMediaByType(
      widget.mediaType,
      refresh: true,
      filters: _currentFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _getTypeColor(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refreshData, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.title.toLowerCase()}...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                      icon: Icon(Icons.clear),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: Icon(Icons.filter_list),
                        label: Text('Apply Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getTypeColor(),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _currentFilters = MediaFilters(
                          type: widget.mediaType,
                          isDeleted: false,
                        );
                        _refreshData();
                      },
                      icon: Icon(Icons.clear_all),
                      label: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Media List
          Expanded(
            child: Consumer<MediaProvider>(
              builder: (context, mediaProvider, child) {
                final mediaList = mediaProvider.getMediaByType(
                  widget.mediaType,
                );
                final isLoading = mediaProvider.isLoadingByType(
                  widget.mediaType,
                );
                final hasMore = mediaProvider.hasMoreByType(widget.mediaType);
                final error = mediaProvider.errorMessage;

                if (error != null && mediaList.isEmpty) {
                  return _buildErrorState(error, mediaProvider);
                }

                if (isLoading && mediaList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (mediaList.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => _refreshData(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount:
                        mediaList.length + (hasMore && isLoading ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= mediaList.length) {
                        // Loading indicator at the bottom
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final media = mediaList[index];
                      return _buildMediaCard(media);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(Media media) {
    return GestureDetector(
      onTap: () => _navigateToMediaDetail(media),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Preview
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  color: _getTypeColor().withOpacity(0.1),
                  child: media.type == MediaType.image && media.fileUrl != null
                      ? Image.network(
                          media.fileUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildMediaPlaceholder(),
                        )
                      : _buildMediaPlaceholder(),
                ),
              ),
            ),

            // Media Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      media.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (media.size != null)
                          Text(
                            media.formattedSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        Text(
                          _formatDate(media.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPlaceholder() {
    return Container(
      color: _getTypeColor().withOpacity(0.1),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          size: 48,
          color: _getTypeColor().withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getTypeIcon(), size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No ${widget.title.toLowerCase()} found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Try uploading some ${widget.title.toLowerCase()} or adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTypeColor(),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, MediaProvider mediaProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            SizedBox(height: 16),
            Text(
              'Error Loading ${widget.title}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    mediaProvider.clearError();
                    _refreshData();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTypeColor(),
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                TextButton(
                  onPressed: () => mediaProvider.clearError(),
                  child: Text('Dismiss'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.mediaType) {
      case MediaType.image:
        return Colors.blue;
      case MediaType.video:
        return Colors.red;
      case MediaType.audio:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.mediaType) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.video_library;
      case MediaType.audio:
        return Icons.audio_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToMediaDetail(Media media) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MediaDetailPage(media: media)),
    ).then((deleted) {
      // If media was deleted, refresh the list
      if (deleted == true) {
        _refreshData();
      }
    });
  }
}
