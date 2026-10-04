import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/audio_recorder_service.dart';
import '../../../core/utils/location_service.dart';
import '../../../core/utils/weather_service.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/mood_badge.dart';
import '../../../core/widgets/paper_background.dart';
import '../../../domain/models/journal_layout.dart';
import '../../../domain/models/mood.dart';
import '../../../domain/models/paper_style.dart';
import '../../providers/database_provider.dart';
import '../../providers/preferences_provider.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String? entryId;
  final String? initialDate;

  const EditorScreen({super.key, this.entryId, this.initialDate});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorderService();
  final _weatherService = WeatherService();

  late String _id;
  late DateTime _entryDate;
  Mood _selectedMood = Mood.all.first;
  int _moodIntensity = 3;
  bool _isFavorite = false;
  PaperStyle _paperStyle = PaperStyle.plain;
  JournalLayout _layout = JournalLayout.classic;

  String? _locationName;
  double? _latitude;
  double? _longitude;
  String? _weatherSummary;
  double? _weatherTemperature;

  final List<String> _photoPaths = [];
  final List<String> _audioPaths = [];
  final List<String> _selectedTagIds = [];

  bool _isRecording = false;
  int _recordingSeconds = 0;
  StreamSubscription? _recordingSub;

  Timer? _autoSaveDebounce;
  String _saveStatus = 'Draft saved';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _id = widget.entryId ?? const Uuid().v4();
    _entryDate = widget.initialDate != null
        ? (DateTime.tryParse(widget.initialDate!) ?? DateTime.now())
        : DateTime.now();

    _loadExistingOrDraft();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  Future<void> _loadExistingOrDraft() async {
    final prefs = ref.read(preferencesProvider);
    _paperStyle = prefs.defaultPaperStyle;
    _layout = prefs.defaultLayout;

    if (widget.entryId != null) {
      // Load existing entry
      final repo = ref.read(journalRepositoryProvider);
      final details = await repo.getEntryById(widget.entryId!);
      if (details != null) {
        _titleController.text = details.entry.title;
        _contentController.text = details.entry.content;
        _entryDate = details.entry.entryDate;
        _selectedMood = details.mood;
        _moodIntensity = details.entry.moodIntensity;
        _isFavorite = details.entry.isFavorite;
        _paperStyle = details.paperStyle;
        _layout = details.layout;
        _locationName = details.entry.locationName;
        _latitude = details.entry.latitude;
        _longitude = details.entry.longitude;
        _weatherSummary = details.entry.weatherSummary;
        _weatherTemperature = details.entry.weatherTemperature;
        _photoPaths.addAll(details.photoAttachments.map((a) => a.uri));
        _audioPaths.addAll(details.audioAttachments.map((a) => a.uri));
        _selectedTagIds.addAll(details.tags.map((t) => t.id));
      }
    } else {
      // Restore draft if exists
      final sp = await SharedPreferences.getInstance();
      final draftTitle = sp.getString('draft_title');
      final draftContent = sp.getString('draft_content');
      if (draftTitle != null && draftTitle.isNotEmpty) {
        _titleController.text = draftTitle;
      }
      if (draftContent != null && draftContent.isNotEmpty) {
        _contentController.text = draftContent;
      }

      // Automatically fetch location & ambient weather if creating new
      _fetchLocationAndWeather();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onTextChanged() {
    _autoSaveDebounce?.cancel();
    setState(() => _saveStatus = 'Saving...');
    _autoSaveDebounce = Timer(const Duration(milliseconds: 800), () async {
      if (widget.entryId == null) {
        final sp = await SharedPreferences.getInstance();
        await sp.setString('draft_title', _titleController.text);
        await sp.setString('draft_content', _contentController.text);
      }
      if (mounted) {
        setState(
          () => _saveStatus =
              'Last saved at ${DateFormat.jm().format(DateTime.now())}',
        );
      }
    });
  }

  Future<void> _fetchLocationAndWeather() async {
    final loc = await LocationService.getCurrentLocation();
    if (loc != null && mounted) {
      setState(() {
        _latitude = loc.latitude;
        _longitude = loc.longitude;
        _locationName = loc.displayName;
      });

      final weather = await _weatherService.fetchCurrentWeather(
        loc.latitude,
        loc.longitude,
      );
      if (weather != null && mounted) {
        setState(() {
          _weatherSummary = weather.summary;
          _weatherTemperature = weather.temperature;
        });
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null) {
        final dir = await getApplicationDocumentsDirectory();
        final photosDir = Directory(p.join(dir.path, 'journal_photos'));
        if (!photosDir.existsSync()) photosDir.createSync(recursive: true);

        final fileName =
            'photo_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
        final savedFile = await File(
          picked.path,
        ).copy(p.join(photosDir.path, fileName));

        setState(() {
          _photoPaths.add(savedFile.path);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleAudioRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stopRecording();
      _recordingSub?.cancel();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _audioPaths.add(path);
        });
      }
    } else {
      await _audioRecorder.startRecording();
      _recordingSub = _audioRecorder.durationStream.listen((sec) {
        if (mounted) setState(() => _recordingSeconds = sec);
      });
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
    }
  }

  Future<void> _saveEntry() async {
    final content = _contentController.text.trim();
    if (content.isEmpty &&
        _titleController.text.trim().isEmpty &&
        _photoPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty journal entry.')),
      );
      return;
    }

    final repo = ref.read(journalRepositoryProvider);
    await repo.saveEntry(
      id: _id,
      title: _titleController.text.trim(),
      content: content,
      entryDate: _entryDate,
      mood: _selectedMood.type.name,
      moodIntensity: _moodIntensity,
      isFavorite: _isFavorite,
      locationName: _locationName,
      latitude: _latitude,
      longitude: _longitude,
      weatherSummary: _weatherSummary,
      weatherTemperature: _weatherTemperature,
      coverImageUri: _photoPaths.isNotEmpty ? _photoPaths.first : null,
      layout: _layout.name,
      paperStyle: _paperStyle.name,
      tagIds: _selectedTagIds,
      photoPaths: _photoPaths,
      audioPaths: _audioPaths,
    );

    // Clear draft
    if (widget.entryId == null) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('draft_title');
      await sp.remove('draft_content');
    }

    if (mounted) {
      context.pop();
    }
  }

  void _showMoodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Mood & Intensity',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Mood.all.map((m) {
                      final isSelected = _selectedMood.type == m.type;
                      return ChoiceChip(
                        label: Text('${m.emoji} ${m.label}'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedMood = m);
                            setSheetState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Intensity:',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: _moodIntensity.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '$_moodIntensity',
                          activeColor: _selectedMood.color,
                          onChanged: (val) {
                            setState(() => _moodIntensity = val.toInt());
                            setSheetState(() {});
                          },
                        ),
                      ),
                      Text(
                        '$_moodIntensity/5',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _recordingSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PaperBackground(
      paperStyle: _paperStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            DateFormat('MMMM d, yyyy').format(_entryDate),
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _isFavorite ? AppColors.vintageGold : null,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
            ),
            TextButton(
              onPressed: _saveEntry,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Status & Paper / Layout Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: (isDark ? Colors.black : Colors.white).withAlpha(40),
              child: Row(
                children: [
                  Text(
                    _saveStatus,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 11,
                      color: isDark
                          ? AppColors.inkMutedDark
                          : AppColors.inkMutedLight,
                    ),
                  ),
                  const Spacer(),
                  // Mood chip trigger
                  GestureDetector(
                    onTap: _showMoodSheet,
                    child: MoodBadge(
                      mood: _selectedMood,
                      intensity: _moodIntensity,
                    ),
                  ),
                ],
              ),
            ),

            // Main Editor Fields
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.inkPrimaryDark
                          : AppColors.inkPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Entry Title...',
                      hintStyle: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        color: isDark
                            ? AppColors.inkMutedDark
                            : AppColors.inkMutedLight,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(height: 12),

                  // Metadata line (Location, Weather)
                  if (_locationName != null || _weatherSummary != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          if (_locationName != null) ...[
                            Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: isDark
                                  ? AppColors.inkMutedDark
                                  : AppColors.inkMutedLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _locationName!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.inkMutedDark
                                    : AppColors.inkMutedLight,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (_weatherSummary != null) ...[
                            Text(
                              '$_weatherSummary (${_weatherTemperature?.round()}°C)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.inkMutedDark
                                    : AppColors.inkMutedLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Body Content Field
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 8,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      height: 1.7,
                      color: isDark
                          ? AppColors.inkPrimaryDark
                          : AppColors.inkPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Begin writing here...',
                      hintStyle: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 15,
                        color: isDark
                            ? AppColors.inkMutedDark
                            : AppColors.inkMutedLight,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  // Attached Photos Preview
                  if (_photoPaths.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photoPaths.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.paperCardBorderLight,
                                  ),
                                  image: DecorationImage(
                                    image: FileImage(File(_photoPaths[index])),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 12,
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _photoPaths.removeAt(index),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black54,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  // Attached Audio Playback
                  if (_audioPaths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._audioPaths.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final path = entry.value;
                      return AudioPlayerWidget(
                        audioPath: path,
                        onDelete: () =>
                            setState(() => _audioPaths.removeAt(idx)),
                      );
                    }),
                  ],
                ],
              ),
            ),

            // Bottom Attachment Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.paperSurfaceDark
                    : AppColors.paperSurfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.paperCardBorderDark
                        : AppColors.paperCardBorderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: 'Take Photo',
                    onPressed: () => _pickPhoto(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_outlined),
                    tooltip: 'Gallery',
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: Icon(
                      _isRecording
                          ? Icons.stop_circle_rounded
                          : Icons.mic_none_rounded,
                      color: _isRecording ? Colors.red : null,
                    ),
                    tooltip: _isRecording ? 'Stop Recording' : 'Record Audio',
                    onPressed: _toggleAudioRecording,
                  ),
                  if (_isRecording)
                    Text(
                      'Recording: ${_recordingSeconds}s',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  const Spacer(),
                  // Paper style selector
                  PopupMenuButton<PaperStyle>(
                    icon: const Icon(Icons.line_weight_rounded),
                    tooltip: 'Paper Style',
                    onSelected: (style) => setState(() => _paperStyle = style),
                    itemBuilder: (context) => PaperStyle.values.map((s) {
                      return PopupMenuItem(value: s, child: Text(s.label));
                    }).toList(),
                  ),
                  // Layout selector
                  PopupMenuButton<JournalLayout>(
                    icon: const Icon(Icons.auto_stories_outlined),
                    tooltip: 'Layout Mode',
                    onSelected: (l) => setState(() => _layout = l),
                    itemBuilder: (context) => JournalLayout.values.map((l) {
                      return PopupMenuItem(value: l, child: Text(l.label));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
