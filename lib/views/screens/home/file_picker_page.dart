import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import '../../../providers/media_provider.dart';
import '../../../data/models/media_model.dart';

class FilePickerPage extends StatefulWidget {
  @override
  _FilePickerPageState createState() => _FilePickerPageState();
}

class _FilePickerPageState extends State<FilePickerPage> {
  final List<_FileWithDescription> _selectedFiles = [];
  bool _isLoading = false;

  // Camera and Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordDuration = Duration.zero;

  // Audio playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentlyPlayingPath;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    for (final file in _selectedFiles) {
      file.descriptionController.dispose();
    }
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _currentlyPlayingPath = null;
        _isPlaying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Files'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Action buttons row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Pick Files button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickFiles,
                    icon: Icon(Icons.attach_file),
                    label: Text('Select Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  // Take Photo button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePhoto,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  // Pick from Gallery button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickFromGallery,
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Audio controls row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Record Audio button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _toggleRecording,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(
                      _isRecording
                          ? 'Stop Recording (${_formatDuration(_recordDuration)})'
                          : 'Record Audio',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording
                          ? Colors.red
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  // Pick Audio button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAudioFile,
                    icon: Icon(Icons.audio_file),
                    label: Text('Pick Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Selected Files list
            Expanded(
              child: _selectedFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'No files selected',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        // Check for audio files by extension or predefined type
                        final isAudio =
                            file.mediaType == MediaType.audio ||
                            _getMediaType(file.file.extension) ==
                                MediaType.audio ||
                            file.file.name.endsWith('.m4a') ||
                            file.file.name.endsWith('.aac');
                        final isCurrentlyPlaying =
                            _currentlyPlayingPath == file.file.path;

                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Preview Section
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: EdgeInsets.only(right: 12),
                                      child: _buildFilePreview(file),
                                    ),

                                    // File info and controls
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // File name
                                          Text(
                                            file.file.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),

                                          // File size and type
                                          Row(
                                            children: [
                                              Icon(
                                                _getFileIcon(
                                                  file.file.extension,
                                                ),
                                                color: _getFileColor(
                                                  file.file.extension,
                                                ),
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                _formatFileSize(file.file.size),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Spacer(),
                                              // Play button for audio files
                                              if (isAudio)
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  icon: Icon(
                                                    isCurrentlyPlaying &&
                                                            _isPlaying
                                                        ? Icons.pause_circle
                                                        : Icons.play_circle,
                                                    color: Colors.orange,
                                                    size: 28,
                                                  ),
                                                  onPressed: () =>
                                                      _toggleAudioPlayback(
                                                        file.file.path!,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Remove button
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _removeFileAt(index),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Description field
                                TextField(
                                  controller: file.descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    hintText:
                                        'Enter description (default: Uploaded via mobile app)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Upload button
            if (_selectedFiles.isNotEmpty)
              Consumer<MediaProvider>(
                builder: (context, mediaProvider, child) {
                  final isUploading = mediaProvider.isUploading || _isLoading;
                  return ElevatedButton(
                    onPressed: isUploading ? null : _uploadFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 50),
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
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Uploading...'),
                            ],
                          )
                        : Text(
                            'Upload ${_selectedFiles.length} File(s)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // File picker
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        for (final file in result.files.where((f) => f.path != null)) {
          // Determine media type from file extension
          final mediaType = _determineMediaType(file.extension);

          // Validate file size before adding
          await _validateAndAddFile(
            filePath: file.path!,
            mediaType: mediaType,
            platformFile: file,
          );
        }
      }
    } catch (e) {
      _showError('Error picking files: $e');
    }
  }

  // Camera functionality
  Future<void> _takePhoto() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError('Camera permission is required');
        return;
      }

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final file = File(photo.path);
        final fileSize = await file.length();

        // Ensure proper file name with extension
        String fileName = path.basename(photo.path);
        if (!fileName.contains('.')) {
          fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }

        final platformFile = PlatformFile(
          path: photo.path,
          name: fileName,
          size: fileSize,
        );

        // Validate file size before adding
        await _validateAndAddFile(
          filePath: photo.path,
          mediaType: MediaType.image,
          platformFile: platformFile,
        );
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  // Gallery picker
  Future<void> _pickFromGallery() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        _showError(
          'Photo library permission is required. Allow it in your settings',
        );
        return;
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (final image in images) {
          final file = File(image.path);
          final fileSize = await file.length();

          // Ensure proper file name with extension
          String fileName = path.basename(image.path);
          if (!fileName.contains('.')) {
            fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }

          final platformFile = PlatformFile(
            path: image.path,
            name: fileName,
            size: fileSize,
          );

          // Validate file size before adding
          await _validateAndAddFile(
            filePath: image.path,
            mediaType: MediaType.image,
            platformFile: platformFile,
          );
        }
      }
    } catch (e) {
      _showError('Error picking from gallery: $e');
    }
  }

  // Audio recording
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showError('Microphone permission is required');
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final fileName =
            'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordingPath = path.join(directory.path, fileName);

        await _audioRecorder.start(const RecordConfig(), path: _recordingPath!);

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
        });

        // Update duration every second
        _startRecordingTimer();
      }
    } catch (e) {
      _showError('Error starting recording: $e');
    }
  }

  void _startRecordingTimer() {
    if (_isRecording) {
      Future.delayed(Duration(seconds: 1), () {
        if (_isRecording) {
          setState(() {
            _recordDuration = _recordDuration + Duration(seconds: 1);
          });
          _startRecordingTimer();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      if (path != null) {
        final file = File(path);
        final fileSize = await file.length();

        // Ensure proper file name with extension
        String fileName =
            'Recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        final platformFile = PlatformFile(
          path: path,
          name: fileName,
          size: fileSize,
        );

        setState(() {
          _isRecording = false;
          _recordDuration = Duration.zero;
        });

        // Validate file size before adding
        await _validateAndAddFile(
          filePath: path,
          mediaType: MediaType.audio,
          platformFile: platformFile,
        );
      }
    } catch (e) {
      _showError('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
        _recordDuration = Duration.zero;
      });
    }
  }

  // Audio file picker
  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null) {
        for (final file in result.files.where((f) => f.path != null)) {
          // Validate file size before adding
          await _validateAndAddFile(
            filePath: file.path!,
            mediaType: MediaType.audio,
            platformFile: file,
          );
        }
      }
    } catch (e) {
      _showError('Error picking audio files: $e');
    }
  }

  // Audio playback
  Future<void> _toggleAudioPlayback(String filePath) async {
    try {
      if (_currentlyPlayingPath == filePath && _isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(filePath));
        setState(() {
          _currentlyPlayingPath = filePath;
        });
      }
    } catch (e) {
      _showError('Error playing audio: $e');
    }
  }

  void _removeFileAt(int index) {
    setState(() {
      _selectedFiles[index].descriptionController.dispose();
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    setState(() => _isLoading = true);

    final requests = _selectedFiles.map((file) {
      final desc = file.descriptionController.text.trim().isEmpty
          ? "Uploaded via mobile app"
          : file.descriptionController.text.trim();

      // Use the predefined media type if available, otherwise detect from extension
      final mediaType =
          file.mediaType ??
          _getMediaType(file.file.extension) ??
          MediaType.image;

      return FileUploadRequest(
        name: file.file.name,
        type: mediaType,
        filePath: file.file.path!,
        description: desc,
      );
    }).toList();

    final result = await mediaProvider.uploadBatch(requests);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.summary),
        backgroundColor: result.successCount > 0 ? Colors.green : Colors.red,
      ),
    );

    if (result.successCount > 0) {
      // Stop any playing audio
      await _audioPlayer.stop();

      // Clear files and dispose controllers
      for (final file in _selectedFiles) {
        file.descriptionController.dispose();
      }

      setState(() => _selectedFiles.clear());
      Navigator.of(context).pop();
    }

    setState(() => _isLoading = false);
  }

  MediaType? _getMediaType(String? extension) {
    if (extension == null) return null;

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'heic':
      case 'heif':
        return MediaType.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return MediaType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
      case 'm4a':
      case 'wma':
      case 'opus':
        return MediaType.audio;
      default:
        return MediaType.image; // fallback
    }
  }

  IconData _getFileIcon(String? extension) {
    final mediaType = _getMediaType(extension);
    switch (mediaType) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.video_file;
      case MediaType.audio:
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String? extension) {
    final mediaType = _getMediaType(extension);
    switch (mediaType) {
      case MediaType.image:
        return Colors.blue;
      case MediaType.video:
        return Colors.purple;
      case MediaType.audio:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Build preview widget for different file types
  Widget _buildFilePreview(_FileWithDescription file) {
    final mediaType =
        file.mediaType ?? _determineMediaType(file.file.extension);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: _buildPreviewContent(file, mediaType),
      ),
    );
  }

  /// Build the actual preview content based on media type
  Widget _buildPreviewContent(_FileWithDescription file, MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        if (file.file.path != null) {
          return GestureDetector(
            onTap: () => _showImagePreview(file.file.path!),
            child: Image.file(
              File(file.file.path!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildIconPreview(mediaType),
            ),
          );
        }
        return _buildIconPreview(mediaType);

      case MediaType.video:
        return GestureDetector(
          onTap: () => _showVideoPreview(file.file.path!),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.grey[200],
                child: Icon(Icons.videocam, size: 32, color: Colors.grey[600]),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
              ),
            ],
          ),
        );

      case MediaType.audio:
        return Container(
          color: Colors.green[50],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.audiotrack, size: 24, color: Colors.green[600]),
              SizedBox(height: 4),
              Text(
                'AUDIO',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        );
    }
  }

  /// Build icon-based preview for non-image files
  Widget _buildIconPreview(MediaType mediaType) {
    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (mediaType) {
      case MediaType.image:
        backgroundColor = Colors.blue[50]!;
        icon = Icons.image;
        iconColor = Colors.blue;
        break;
      case MediaType.video:
        backgroundColor = Colors.red[50]!;
        icon = Icons.video_library;
        iconColor = Colors.red;
        break;
      case MediaType.audio:
        backgroundColor = Colors.green[50]!;
        icon = Icons.audio_file;
        iconColor = Colors.green;
        break;
    }

    return Container(
      color: backgroundColor,
      child: Center(child: Icon(icon, size: 32, color: iconColor)),
    );
  }

  /// Show full-screen image preview
  void _showImagePreview(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImagePreview(imagePath: imagePath),
      ),
    );
  }

  /// Show video preview (could be enhanced with video player)
  void _showVideoPreview(String videoPath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video preview: ${path.basename(videoPath)}'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  /// Validate file size and show appropriate dialogs
  Future<bool> _validateAndAddFile({
    required String filePath,
    required MediaType mediaType,
    required PlatformFile platformFile,
  }) async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    final validationResult = await mediaProvider.validateFileSize(
      filePath: filePath,
      mediaType: mediaType,
    );

    if (!validationResult.isValid) {
      // Show error dialog for files that exceed maximum size
      _showFileSizeErrorDialog(validationResult.errorMessage!);
      return false;
    }

    if (validationResult.hasWarning) {
      // Show warning dialog but allow user to continue
      return await _showFileSizeWarningDialog(
        validationResult.warningMessage!,
        platformFile,
        mediaType,
      );
    }

    // File is valid, add it directly
    _addFileToList(platformFile, mediaType);
    return true;
  }

  /// Show error dialog for files that exceed maximum size
  void _showFileSizeErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('File Too Large'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show warning dialog for files that exceed warning threshold
  Future<bool> _showFileSizeWarningDialog(
    String message,
    PlatformFile platformFile,
    MediaType mediaType,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Large File Warning'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  const SizedBox(height: 8),
                  const Text(
                    'Do you want to continue with this file?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    _addFileToList(platformFile, mediaType);
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Add file to the selected files list
  void _addFileToList(PlatformFile platformFile, MediaType mediaType) {
    setState(() {
      _selectedFiles.add(
        _FileWithDescription(platformFile, mediaType: mediaType),
      );
    });
  }

  /// Determine media type from file extension
  MediaType _determineMediaType(String? extension) {
    if (extension == null) return MediaType.image;

    final ext = extension.toLowerCase();

    // Image extensions
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'].contains(ext)) {
      return MediaType.image;
    }

    // Video extensions
    if ([
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'webm',
      'mkv',
      '3gp',
    ].contains(ext)) {
      return MediaType.video;
    }

    // Audio extensions
    if (['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma'].contains(ext)) {
      return MediaType.audio;
    }

    return MediaType.image; // Default fallback
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

class _FileWithDescription {
  final PlatformFile file;
  final TextEditingController descriptionController = TextEditingController();
  final MediaType? mediaType; // Store the media type explicitly

  _FileWithDescription(this.file, {this.mediaType});
}

/// Full-screen image preview widget
class _FullScreenImagePreview extends StatelessWidget {
  final String imagePath;

  const _FullScreenImagePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          path.basename(imagePath),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Could not load image',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
