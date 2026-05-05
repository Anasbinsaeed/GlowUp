import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/cute_card.dart';
import '../services/notification_service.dart';

class NotificationTone {
  final String id;
  final String name;
  final String emoji;
  final String? assetFile; // null = default system tone, empty = silent

  const NotificationTone({
    required this.id,
    required this.name,
    required this.emoji,
    this.assetFile,
  });
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedToneId = 'default';
  String? _playingToneId;
  final AudioPlayer _player = AudioPlayer();

  static const _prefKeyEnabled = 'notifications_enabled';
  static const _prefKeyTone = 'notification_tone';

  static const _tones = [
    NotificationTone(
      id: 'default',
      name: 'Default',
      emoji: '🔔',
      assetFile: null, // uses system default
    ),
    NotificationTone(
      id: 'sparkle',
      name: 'Sparkle',
      emoji: '✨',
      assetFile: 'sounds/sparkle.mp3',
    ),
    NotificationTone(
      id: 'bloom',
      name: 'Bloom',
      emoji: '🌸',
      assetFile: 'sounds/bloom.mp3',
    ),
    NotificationTone(
      id: 'chime',
      name: 'Chime',
      emoji: '🎵',
      assetFile: 'sounds/chime.mp3',
    ),
    NotificationTone(
      id: 'bubble',
      name: 'Bubble',
      emoji: '🫧',
      assetFile: 'sounds/bubble.mp3',
    ),
    NotificationTone(
      id: 'pop',
      name: 'Pop',
      emoji: '🎈',
      assetFile: 'sounds/pop.mp3',
    ),
    NotificationTone(
      id: 'crystal',
      name: 'Crystal',
      emoji: '💎',
      assetFile: 'sounds/crystal.mp3',
    ),
    NotificationTone(
      id: 'breeze',
      name: 'Breeze',
      emoji: '🌬️',
      assetFile: 'sounds/breeze.mp3',
    ),
    NotificationTone(
      id: 'drip',
      name: 'Drip',
      emoji: '💧',
      assetFile: 'sounds/drip.mp3',
    ),
    NotificationTone(
      id: 'glow',
      name: 'Glow',
      emoji: '💫',
      assetFile: 'sounds/glow.mp3',
    ),
    NotificationTone(
      id: 'soft',
      name: 'Soft Bell',
      emoji: '🔕',
      assetFile: 'sounds/soft.mp3',
    ),
    NotificationTone(
      id: 'silent',
      name: 'Silent',
      emoji: '🤫',
      assetFile: '', // empty = no sound
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _player.setReleaseMode(ReleaseMode.stop);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingToneId = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_prefKeyEnabled) ?? true;
      _selectedToneId = prefs.getString(_prefKeyTone) ?? 'default';
    });
  }

  Future<void> _setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, value);
    setState(() => _notificationsEnabled = value);

    if (!value) {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _selectTone(NotificationTone tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyTone, tone.id);
    setState(() => _selectedToneId = tone.id);
    // Preview first, then reinit channel in background
    _previewTone(tone);
    NotificationService().reinitChannel();
  }

  Future<void> _previewTone(NotificationTone tone) async {
    await _player.stop();

    // Silent — no preview
    if (tone.assetFile == '') return;

    // Default — play system notification sound via platform channel
    if (tone.assetFile == null) {
      setState(() => _playingToneId = tone.id);
      try {
        const platform = MethodChannel('com.example.cuteapp/ringtone');
        await platform.invokeMethod('playDefaultNotification');
      } catch (_) {
        // fallback: just show playing state briefly
      }
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _playingToneId = null);
      return;
    }

    setState(() => _playingToneId = tone.id);
    try {
      await _player.play(AssetSource(tone.assetFile!));
    } catch (e) {
      debugPrint('Audio preview error: $e');
      if (mounted) setState(() => _playingToneId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.gradientBackground),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? AppColors.darkShadow
                                  : AppColors.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16, color: context.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Notifications 🔔',
                      style: AppTextStyles.heading(
                          fontSize: 22, color: context.textPrimary),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enable/Disable toggle
                      CuteCard(
                        color: isDark ? null : context.cardColor,
                        gradient: isDark ? AppColors.gradientPinkDark : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : AppColors.cream,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child:
                                    Text('🔔', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable Notifications',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _notificationsEnabled
                                        ? 'Reminders will notify you ✨'
                                        : 'All notifications are off 🤫',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _notificationsEnabled,
                              onChanged: _setEnabled,
                              activeThumbColor: Colors.white,
                              activeTrackColor: context.accentPink,
                              inactiveThumbColor: context.textTertiary,
                              inactiveTrackColor:
                                  isDark ? AppColors.darkCard : AppColors.cream,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Tone section
                      AnimatedOpacity(
                        opacity: _notificationsEnabled ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 12),
                              child: Row(
                                children: [
                                  const Text('🎵',
                                      style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'NOTIFICATION TONE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: context.textSecondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? AppColors.darkShadow
                                        : AppColors.shadowColor,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: _tones.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final tone = entry.value;
                                  final isSelected = _selectedToneId == tone.id;
                                  final isPlaying = _playingToneId == tone.id;
                                  final isLast = i == _tones.length - 1;

                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: _notificationsEnabled
                                            ? () => _selectTone(tone)
                                            : null,
                                        borderRadius: BorderRadius.vertical(
                                          top: i == 0
                                              ? const Radius.circular(24)
                                              : Radius.zero,
                                          bottom: isLast
                                              ? const Radius.circular(24)
                                              : Radius.zero,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 13),
                                          child: Row(
                                            children: [
                                              AnimatedScale(
                                                scale: isPlaying ? 1.35 : 1.0,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Text(tone.emoji,
                                                    style: const TextStyle(
                                                        fontSize: 22)),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tone.name,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                        color: isSelected
                                                            ? context.accentPink
                                                            : context
                                                                .textPrimary,
                                                      ),
                                                    ),
                                                    if (tone.assetFile == null)
                                                      Text(
                                                        "Uses your phone's default tone",
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: context
                                                                .textTertiary),
                                                      )
                                                    else if (tone.assetFile ==
                                                        '')
                                                      Text(
                                                        'No sound',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: context
                                                                .textTertiary),
                                                      )
                                                    else if (isPlaying)
                                                      Text(
                                                        'Playing...',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: context
                                                                .accentPink,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected
                                                      ? context.accentPink
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? context.accentPink
                                                        : context.textTertiary
                                                            .withValues(
                                                                alpha: 0.4),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(Icons.check,
                                                        size: 13,
                                                        color: Colors.white)
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          height: 1,
                                          indent: 56,
                                          endIndent: 16,
                                          color: context.textTertiary
                                              .withValues(alpha: 0.15),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                'Tap any tone to preview it 🎶',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.textTertiary,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(delay: 150.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
