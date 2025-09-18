// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:media_handler/providers/auth_provider.dart';
import 'package:media_handler/providers/user_provider.dart';
import 'package:media_handler/providers/media_provider.dart';
import 'package:media_handler/data/models/media_model.dart';
import 'package:media_handler/views/screens/media/media_list_page.dart';
import 'package:media_handler/views/screens/media/media_detail_page.dart';
import 'package:media_handler/views/screens/home/file_picker_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize media loading once when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

      // Only load media if user is authenticated and media hasn't been initialized
      if (authProvider.isAuthenticated &&
          !mediaProvider.isHomePageInitialized) {
        mediaProvider.loadHomePageMedia();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Consumer2<UserProvider, AuthProvider>(
          builder: (context, userProvider, authProvider, child) {
            // Use AuthProvider's currentUser as primary source, fallback to UserProvider
            final user = authProvider.currentUser ?? userProvider.currentUser;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, ${user?.firstName ?? 'User'}!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Media Display
                Text(
                  'Your Media',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                Expanded(
                  child: Consumer<MediaProvider>(
                    builder: (context, mediaProvider, child) {
                      if (mediaProvider.errorMessage != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 16),
                              Text(
                                'Error: ${mediaProvider.errorMessage}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  mediaProvider.clearError();
                                  mediaProvider.loadHomePageMedia();
                                },
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final bool isLoadingAny =
                          mediaProvider.isLoadingByType(MediaType.image) ||
                          mediaProvider.isLoadingByType(MediaType.video) ||
                          mediaProvider.isLoadingByType(MediaType.audio);

                      if (isLoadingAny) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // Check if all media types are empty
                      final bool hasNoMedia =
                          mediaProvider
                              .getMediaByType(MediaType.image)
                              .isEmpty &&
                          mediaProvider
                              .getMediaByType(MediaType.video)
                              .isEmpty &&
                          mediaProvider.getMediaByType(MediaType.audio).isEmpty;

                      if (hasNoMedia && mediaProvider.isHomePageInitialized) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Media Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start by uploading your first media file!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FilePickerPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add),
                                label: Text('Upload Media'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Images Section
                            _buildMediaSection(
                              context,
                              'Images',
                              MediaType.image,
                              mediaProvider.getMediaByType(MediaType.image),
                              Icons.image,
                              Colors.blue,
                            ),
                            SizedBox(height: 24),

                            // Videos Section
                            _buildMediaSection(
                              context,
                              'Videos',
                              MediaType.video,
                              mediaProvider.getMediaByType(MediaType.video),
                              Icons.video_library,
                              Colors.red,
                            ),
                            SizedBox(height: 24),

                            // Audio Section
                            _buildMediaSection(
                              context,
                              'Audio',
                              MediaType.audio,
                              mediaProvider.getMediaByType(MediaType.audio),
                              Icons.audio_file,
                              Colors.green,
                            ),
                            SizedBox(height: 24),

                            // Quick Actions
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaSection(
    BuildContext context,
    String title,
    MediaType type,
    List<Media> mediaList,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            if (mediaList.isNotEmpty)
              TextButton(
                onPressed: () => _navigateToMediaList(context, type),
                child: Text('See More', style: TextStyle(color: color)),
              ),
          ],
        ),
        SizedBox(height: 12),
        if (mediaList.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.grey[400], size: 32),
                SizedBox(height: 8),
                Text(
                  'No ${title.toLowerCase()} yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return GestureDetector(
                  onTap: () => _navigateToMediaDetail(context, media),
                  child: Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Media thumbnail/placeholder
                          Container(
                            color: color.withOpacity(0.1),
                            child: media.type == MediaType.image
                                ? (media.fileUrl != null
                                      ? Image.network(
                                          media.fileUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildMediaPlaceholder(
                                                    icon,
                                                    color,
                                                  ),
                                        )
                                      : _buildMediaPlaceholder(icon, color))
                                : _buildMediaPlaceholder(icon, color),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                          // Media info
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  media.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (media.size != null)
                                  Text(
                                    media.formattedSize,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMediaPlaceholder(IconData icon, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(child: Icon(icon, size: 32, color: color.withOpacity(0.6))),
    );
  }

  void _navigateToMediaList(BuildContext context, MediaType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaListPage(
          mediaType: type,
          title:
              '${type.name.substring(0, 1).toUpperCase()}${type.name.substring(1)}s',
        ),
      ),
    );
  }

  void _navigateToMediaDetail(BuildContext context, Media media) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MediaDetailPage(media: media)),
    );
  }
}
