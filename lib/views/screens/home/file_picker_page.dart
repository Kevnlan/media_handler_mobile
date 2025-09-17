import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/models/media_model.dart';
import '../../../providers/media_provider.dart';

class FilePickerPage extends StatefulWidget {
  @override
  _FilePickerPageState createState() => _FilePickerPageState();
}

class _FilePickerPageState extends State<FilePickerPage> {
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Files'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Choose Files to Upload',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select images, videos, documents, or any other files',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // File Selection Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickFiles(FileType.media),
                    icon: Icon(Icons.photo_library),
                    label: Text('Photos & Videos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickFiles(FileType.any),
                    icon: Icon(Icons.attach_file),
                    label: Text('All Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _pickFiles(
                      FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                    ),
              icon: Icon(Icons.description),
              label: Text('Documents Only'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 24),

            // Selected Files List
            if (_selectedFiles.isNotEmpty) ...[
              Text(
                'Selected Files (${_selectedFiles.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
            ],

            Expanded(
              child: _selectedFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No files selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: _getFileIcon(file.extension),
                            title: Text(
                              file.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              _formatFileSize(file.size),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeFile(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Upload Button
            if (_selectedFiles.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Consumer<MediaProvider>(
                  builder: (context, mediaProvider, child) {
                    final isUploading = mediaProvider.isUploading || _isLoading;

                    return ElevatedButton(
                      onPressed: isUploading ? null : _uploadFiles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Uploading...'),
                              ],
                            )
                          : Text(
                              'Upload ${_selectedFiles.length} File${_selectedFiles.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles(
    FileType type, {
    List<String>? allowedExtensions,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      int successCount = 0;
      int errorCount = 0;

      for (final file in _selectedFiles) {
        if (file.path == null) {
          errorCount++;
          continue;
        }

        // Determine media type based on file extension
        final mediaType = _getMediaType(file.extension);
        if (mediaType == null) {
          errorCount++;
          continue;
        }

        final result = await mediaProvider.uploadMedia(
          name: file.name,
          type: mediaType,
          filePath: file.path!,
          description: 'Uploaded via mobile app',
        );

        if (result != null) {
          successCount++;
        } else {
          errorCount++;
        }
      }

      // Show result message
      final message = successCount > 0
          ? errorCount > 0
                ? '$successCount file(s) uploaded successfully, $errorCount failed'
                : '$successCount file(s) uploaded successfully!'
          : 'All uploads failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successCount > 0 ? Colors.green : Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      if (successCount > 0) {
        setState(() {
          _selectedFiles.clear();
        });

        // Navigate back on success
        Navigator.of(context).pop();
      }

      // Show any provider errors
      if (mediaProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${mediaProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
        mediaProvider.clearError();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  MediaType? _getMediaType(String? extension) {
    if (extension == null) return null;

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return MediaType.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'webm':
      case 'mkv':
        return MediaType.video;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
      case 'm4a':
        return MediaType.audio;
      default:
        // For documents and other files, default to image
        // You might want to add a 'document' type to your MediaType enum
        return MediaType.image;
    }
  }

  Widget _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icon(Icons.image, color: Colors.green);
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icon(Icons.video_file, color: Colors.blue);
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icon(Icons.audio_file, color: Colors.orange);
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return Icon(Icons.description, color: Colors.blue);
      case 'txt':
        return Icon(Icons.text_snippet, color: Colors.grey);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey[600]);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
