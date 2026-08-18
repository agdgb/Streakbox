import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';
import '../../../state/habit_providers.dart';
import '../../../state/settings_provider.dart';

/// Comprehensive Emoji item with keywords for instant search.
class _EmojiItem {
  final String emoji;
  final String name;
  final List<String> keywords;
  final String category;

  const _EmojiItem(this.emoji, this.name, this.keywords, this.category);
}

/// Flexible Emoji Picker Sheet supporting both Full 3,000+ Emoji Keyboard & Curated Mode,
/// with instant 1-tap emoji marking and toggleable notes.
class DayDetailSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final DateTime date;
  final HabitEntry? currentEntry;

  const DayDetailSheet({
    super.key,
    required this.habit,
    required this.date,
    this.currentEntry,
  });

  static Future<void> show(
    BuildContext context, {
    required Habit habit,
    required DateTime date,
    HabitEntry? currentEntry,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DayDetailSheet(habit: habit, date: date, currentEntry: currentEntry),
    );
  }

  @override
  ConsumerState<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends ConsumerState<DayDetailSheet> {
  late bool _isChecked;
  late String _selectedEmoji;
  late final TextEditingController _noteController;
  late final TextEditingController _searchController;
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  bool _showNotes = false;

  static const List<String> _categoryIcons = ['⏱️', '😃', '🏃', '👏', '✨'];
  static const List<String> _categoryNames = [
    'Status',
    'Smileys',
    'Habits',
    'Gestures',
    'Symbols',
  ];

  static const List<_EmojiItem> _allEmojis = [
    // Status & Marks (✅ & ❌ prominent)
    _EmojiItem('✅', 'Check Mark Green', [
      'check',
      'done',
      'yes',
      'tick',
      'pass',
      'complete',
      'green',
    ], 'Status'),
    _EmojiItem('❌', 'Cross Mark Red', [
      'cross',
      'no',
      'x',
      'fail',
      'cancel',
      'wrong',
      'red',
      'miss',
    ], 'Status'),
    _EmojiItem('✔️', 'Check Mark', ['check', 'done', 'tick', 'yes'], 'Status'),
    _EmojiItem('☑️', 'Check Box', ['check', 'box', 'tick', 'done'], 'Status'),
    _EmojiItem('🔥', 'Fire', [
      'fire',
      'flame',
      'hot',
      'streak',
      'lit',
    ], 'Status'),
    _EmojiItem('⭐', 'Star', ['star', 'favorite', 'best', 'gold'], 'Status'),
    _EmojiItem('🌟', 'Glowing Star', [
      'star',
      'sparkle',
      'shine',
      'glow',
    ], 'Status'),
    _EmojiItem('💯', 'Hundred Points', [
      '100',
      'hundred',
      'perfect',
      'score',
    ], 'Status'),
    _EmojiItem('🎯', 'Bullseye', ['target', 'goal', 'hit', 'focus'], 'Status'),
    _EmojiItem('🏆', 'Trophy', [
      'trophy',
      'winner',
      'cup',
      'first',
      'champion',
    ], 'Status'),
    _EmojiItem('🥇', '1st Place Medal', [
      'medal',
      'gold',
      'winner',
      'first',
    ], 'Status'),
    _EmojiItem('🚫', 'Prohibited', [
      'prohibited',
      'no',
      'stop',
      'forbidden',
    ], 'Status'),

    // Smileys & Emotions
    _EmojiItem('😆', 'Grinning Squinting Face', [
      'laugh',
      'happy',
      'smile',
      'joy',
    ], 'Smileys'),
    _EmojiItem('😊', 'Smiling Face with Smiling Eyes', [
      'happy',
      'warm',
      'smile',
    ], 'Smileys'),
    _EmojiItem('😎', 'Sunglasses Face', [
      'cool',
      'done',
      'easy',
      'awesome',
    ], 'Smileys'),
    _EmojiItem('🥳', 'Partying Face', [
      'party',
      'celebrate',
      'yay',
      'woohoo',
    ], 'Smileys'),
    _EmojiItem('💪', 'Flexed Biceps', [
      'muscle',
      'strong',
      'power',
      'workout',
    ], 'Smileys'),
    _EmojiItem('🙌', 'Raising Hands', [
      'celebrate',
      'yay',
      'praise',
      'hooray',
    ], 'Smileys'),
    _EmojiItem('😴', 'Sleeping Face', [
      'sleep',
      'tired',
      'rest',
      'bed',
    ], 'Smileys'),
    _EmojiItem('🥺', 'Pleading Face', [
      'plead',
      'puppy',
      'beg',
      'sad',
    ], 'Smileys'),
    _EmojiItem('😤', 'Triumphant Face', [
      'determined',
      'proud',
      'grind',
    ], 'Smileys'),
    _EmojiItem('😌', 'Relieved Face', ['calm', 'peace', 'relief'], 'Smileys'),
    _EmojiItem('🤯', 'Exploding Head', [
      'mind blown',
      'shock',
      'crazy',
    ], 'Smileys'),
    _EmojiItem('🤔', 'Thinking Face', [
      'think',
      'wonder',
      'consider',
    ], 'Smileys'),
    _EmojiItem('😏', 'Smirking Face', ['smirk', 'cool', 'flirt'], 'Smileys'),
    _EmojiItem('🥱', 'Yawning Face', [
      'yawn',
      'tired',
      'bored',
      'sleepy',
    ], 'Smileys'),
    _EmojiItem('🤓', 'Nerd Face', [
      'nerd',
      'study',
      'smart',
      'glasses',
      'geek',
    ], 'Smileys'),

    // Habits & Fitness
    _EmojiItem('🏃', 'Running', [
      'run',
      'cardio',
      'jog',
      'sprint',
      'workout',
    ], 'Habits'),
    _EmojiItem('🚴', 'Cycling', [
      'bike',
      'cycle',
      'biking',
      'workout',
    ], 'Habits'),
    _EmojiItem('🏋️', 'Weight Lifting', [
      'gym',
      'lift',
      'weights',
      'strength',
      'workout',
    ], 'Habits'),
    _EmojiItem('🧘', 'Meditation / Yoga', [
      'meditate',
      'yoga',
      'calm',
      'peace',
      'zen',
    ], 'Habits'),
    _EmojiItem('💧', 'Water Droplet', [
      'water',
      'hydrate',
      'drink',
      'liquid',
    ], 'Habits'),
    _EmojiItem('🥗', 'Green Salad', [
      'salad',
      'healthy',
      'diet',
      'food',
      'eat',
    ], 'Habits'),
    _EmojiItem('📖', 'Open Book', [
      'book',
      'read',
      'reading',
      'study',
      'learn',
    ], 'Habits'),
    _EmojiItem('✍️', 'Writing Hand', [
      'write',
      'journal',
      'essay',
      'notes',
      'pen',
    ], 'Habits'),
    _EmojiItem('💻', 'Laptop', [
      'code',
      'work',
      'laptop',
      'program',
      'computer',
    ], 'Habits'),
    _EmojiItem('🎨', 'Artist Palette', [
      'art',
      'draw',
      'paint',
      'creative',
      'design',
    ], 'Habits'),
    _EmojiItem('🎵', 'Musical Note', [
      'music',
      'song',
      'sing',
      'instrument',
    ], 'Habits'),
    _EmojiItem('💤', 'ZZZ Sleep', ['sleep', 'nap', 'rest', 'bed'], 'Habits'),
    _EmojiItem('⏰', 'Alarm Clock', [
      'alarm',
      'time',
      'wake',
      'early',
      'clock',
    ], 'Habits'),
    _EmojiItem('🌱', 'Seedling', [
      'plant',
      'growth',
      'nature',
      'green',
    ], 'Habits'),
    _EmojiItem('💊', 'Pill', ['vitamin', 'medicine', 'health'], 'Habits'),
    _EmojiItem('🧹', 'Broom Clean', [
      'clean',
      'sweep',
      'tidy',
      'chore',
    ], 'Habits'),
    _EmojiItem('🐕', 'Dog Walk', ['pet', 'dog', 'walk', 'animal'], 'Habits'),
    _EmojiItem('☕', 'Hot Coffee', [
      'coffee',
      'caffeine',
      'tea',
      'drink',
    ], 'Habits'),

    // Gestures & Actions
    _EmojiItem('💪', 'Flexed Biceps', [
      'muscle',
      'strong',
      'arm',
      'flex',
    ], 'Gestures'),
    _EmojiItem('👏', 'Clapping Hands', [
      'clap',
      'applause',
      'praise',
      'bravo',
    ], 'Gestures'),
    _EmojiItem('🙏', 'Folded Hands', [
      'pray',
      'thanks',
      'gratitude',
      'please',
      'namaste',
    ], 'Gestures'),
    _EmojiItem('👍', 'Thumbs Up', [
      'yes',
      'good',
      'like',
      'approve',
      'ok',
    ], 'Gestures'),
    _EmojiItem('👎', 'Thumbs Down', [
      'no',
      'bad',
      'dislike',
      'disapprove',
    ], 'Gestures'),
    _EmojiItem('✌️', 'Victory Hand', ['peace', 'victory', 'two'], 'Gestures'),
    _EmojiItem('🤝', 'Handshake', [
      'deal',
      'agree',
      'meeting',
      'shake',
    ], 'Gestures'),
    _EmojiItem('🙌', 'Raising Hands', [
      'celebrate',
      'hooray',
      'yay',
      'praise',
    ], 'Gestures'),
    _EmojiItem('👊', 'Oncoming Fist', [
      'fist bump',
      'punch',
      'bro',
    ], 'Gestures'),
    _EmojiItem('🤞', 'Crossed Fingers', ['luck', 'hope', 'wish'], 'Gestures'),
    _EmojiItem('👌', 'OK Hand', ['ok', 'perfect', 'fine'], 'Gestures'),
    _EmojiItem('❤️', 'Red Heart', ['heart', 'love', 'red'], 'Gestures'),
    _EmojiItem('🧡', 'Orange Heart', ['heart', 'orange'], 'Gestures'),
    _EmojiItem('💚', 'Green Heart', ['heart', 'green'], 'Gestures'),
    _EmojiItem('💙', 'Blue Heart', ['heart', 'blue'], 'Gestures'),
    _EmojiItem('💜', 'Purple Heart', ['heart', 'purple'], 'Gestures'),

    // Symbols & Celebrations
    _EmojiItem('✨', 'Sparkles', [
      'sparkle',
      'magic',
      'shine',
      'special',
    ], 'Symbols'),
    _EmojiItem('🚀', 'Rocket', [
      'rocket',
      'launch',
      'fast',
      'growth',
      'future',
    ], 'Symbols'),
    _EmojiItem('⚡', 'High Voltage', [
      'lightning',
      'energy',
      'fast',
      'power',
    ], 'Symbols'),
    _EmojiItem('🎉', 'Party Popper', [
      'party',
      'celebrate',
      'congrats',
    ], 'Symbols'),
    _EmojiItem('💡', 'Light Bulb', [
      'idea',
      'bright',
      'smart',
      'think',
    ], 'Symbols'),
    _EmojiItem('💎', 'Gem Stone', ['diamond', 'shine', 'value'], 'Symbols'),
    _EmojiItem('👑', 'Crown', ['king', 'queen', 'crown', 'best'], 'Symbols'),
    _EmojiItem('🧠', 'Brain', ['smart', 'focus', 'mind', 'iq'], 'Symbols'),
    _EmojiItem('🏆', 'Trophy', ['win', 'champion', 'first'], 'Symbols'),
    _EmojiItem('🎖️', 'Military Medal', ['award', 'honor'], 'Symbols'),
    _EmojiItem('☀️', 'Sun', ['sunny', 'morning', 'day', 'warm'], 'Symbols'),
    _EmojiItem('🌙', 'Crescent Moon', ['night', 'sleep', 'moon'], 'Symbols'),
    _EmojiItem('🌈', 'Rainbow', [
      'rainbow',
      'colorful',
      'pride',
      'sky',
    ], 'Symbols'),
  ];

  @override
  void initState() {
    super.initState();
    _isChecked = widget.currentEntry != null;
    final notes = widget.currentEntry?.notes ?? '';
    _selectedEmoji = _extractLeadingEmoji(notes);

    String cleanNotes = notes;
    if (_selectedEmoji.isNotEmpty && notes.startsWith(_selectedEmoji)) {
      cleanNotes = notes.substring(_selectedEmoji.length).trim();
    }
    _noteController = TextEditingController(text: cleanNotes);
    _searchController = TextEditingController();
    _showNotes = cleanNotes.isNotEmpty;
  }

  String _extractLeadingEmoji(String text) {
    if (text.isEmpty) return '';
    final words = text.split(' ');
    if (words.isNotEmpty) {
      final first = words.first;
      final runes = first.runes.toList();
      if (runes.isNotEmpty && (runes.first > 0x2000 || first.length <= 4)) {
        return first;
      }
    }
    return '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_EmojiItem> get _filteredEmojis {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      return _allEmojis.where((item) {
        if (item.emoji.contains(query) ||
            item.name.toLowerCase().contains(query)) {
          return true;
        }
        return item.keywords.any((k) => k.contains(query));
      }).toList();
    }

    final currentCategory = _categoryNames[_selectedCategoryIndex];
    return _allEmojis
        .where((item) => item.category == currentCategory)
        .toList();
  }

  Future<void> _handleInstantEmojiSelect(String emoji) async {
    final dateKey = AppDateUtils.formatDateKey(widget.date);
    await ref
        .read(selectedHabitEntriesProvider.notifier)
        .setEntryDetails(
          dateKey: dateKey,
          isChecked: true,
          notes: emoji,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSave() async {
    final dateKey = AppDateUtils.formatDateKey(widget.date);
    String rawNotes = _noteController.text.trim();

    String finalNotes = rawNotes;
    if (_selectedEmoji.isNotEmpty) {
      finalNotes = '$_selectedEmoji $rawNotes'.trim();
    }

    await ref
        .read(selectedHabitEntriesProvider.notifier)
        .setEntryDetails(
          dateKey: dateKey,
          isChecked: _isChecked,
          notes: finalNotes,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitColor = widget.habit.color;
    final formattedDate =
        '${widget.date.day} ${AppDateUtils.formatMonthYear(widget.date)}';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final pickerMode = ref.watch(emojiPickerStyleProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: bottomInset + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header: Date, Habit, Mode Switcher & Check-in Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: AppTextStyles.titleLarge(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: habitColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.habit.name,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: habitColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedEmoji.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Inline Mode Switcher (Full Keyboard vs Curated)
                  Tooltip(
                    message: pickerMode == EmojiPickerStyle.fullKeyboard
                        ? 'Switch to Quick Mode'
                        : 'Switch to Full Keyboard',
                    child: IconButton(
                      icon: Icon(
                        pickerMode == EmojiPickerStyle.fullKeyboard
                            ? Icons.grid_view_rounded
                            : Icons.keyboard_rounded,
                        size: 20,
                        color: habitColor,
                      ),
                      onPressed: () {
                        ref
                            .read(emojiPickerStyleProvider.notifier)
                            .toggleStyle();
                      },
                    ),
                  ),
                  Switch(
                    value: _isChecked,
                    activeTrackColor: habitColor,
                    onChanged: (val) {
                      setState(() {
                        _isChecked = val;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xs),

          // Body: Either Full Emoji Keyboard (3000+ emojis) or Curated Quick Grid
          Expanded(
            child: pickerMode == EmojiPickerStyle.fullKeyboard
                ? ClipRRect(
                    borderRadius: AppSpacing.roundedMd,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        if (!_showNotes) {
                          _handleInstantEmojiSelect(emoji.emoji);
                        } else {
                          setState(() {
                            _selectedEmoji = emoji.emoji;
                            _isChecked = true;
                          });
                        }
                      },
                      config: Config(
                        height: 270,
                        checkPlatformCompatibility: true,
                        viewOrderConfig: const ViewOrderConfig(
                          top: EmojiPickerItem.categoryBar,
                          middle: EmojiPickerItem.emojiView,
                          bottom: EmojiPickerItem.searchBar,
                        ),
                        categoryViewConfig: CategoryViewConfig(
                          backgroundColor: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          indicatorColor: habitColor,
                          iconColorSelected: habitColor,
                          iconColor: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                          backspaceColor: habitColor,
                        ),
                        emojiViewConfig: EmojiViewConfig(
                          columns: 7,
                          emojiSizeMax: 26,
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                        ),
                        searchViewConfig: SearchViewConfig(
                          backgroundColor: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          buttonIconColor: habitColor,
                        ),
                      ),
                    ),
                  )
                : _buildCuratedView(context, isDark, habitColor),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Toggleable Note Section (Opt-in)
          if (!_showNotes)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showNotes = true;
                  });
                },
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text(
                  '✍️ Add Note / Reflection',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            )
          else ...[
            // Optional Day Note / Reflection
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    maxLines: 1,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Day Notes / Reflection (e.g. 30 mins reading)...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showNotes = false;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: 'Hide Note Field',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Action Buttons
            Row(
              children: [
                if (_selectedEmoji.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedEmoji = '';
                        });
                      },
                      child: const Text('Remove Sticker'),
                    ),
                  ),
                Expanded(
                  child: FilledButton(
                    onPressed: _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: habitColor,
                      foregroundColor: habitColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.roundedMd,
                      ),
                    ),
                    child: Text(
                      _isChecked ? 'Save Check-in' : 'Clear Check-in',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCuratedView(
    BuildContext context,
    bool isDark,
    Color habitColor,
  ) {
    final displayEmojis = _filteredEmojis;

    return Column(
      children: [
        // Search Bar for Quick Filtering
        SizedBox(
          height: 36,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search 3,000+ emojis (fire, run, star)...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
              prefixIcon: const Icon(Icons.search, size: 16),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.roundedMd,
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Category Pills (Only show if not searching)
        if (_searchQuery.isEmpty)
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(_categoryIcons.length, (i) {
                final isSelected = _selectedCategoryIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = i;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? habitColor.withValues(alpha: isDark ? 0.25 : 0.15)
                            : Colors.transparent,
                        borderRadius: AppSpacing.roundedSm,
                        border: isSelected
                            ? Border.all(color: habitColor, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        _categoryIcons[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

        // Scrollable Emoji Grid
        Expanded(
          child: displayEmojis.isEmpty
              ? Center(
                  child: Text(
                    'No matching emojis found for "$_searchQuery"',
                    style: AppTextStyles.bodySmall(context),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: displayEmojis.length,
                  itemBuilder: (context, index) {
                    final item = displayEmojis[index];
                    final isPicked = _selectedEmoji == item.emoji;

                    return Tooltip(
                      message: item.name,
                      child: GestureDetector(
                        onTap: () {
                          if (!_showNotes) {
                            // Instant 1-tap save and dismiss!
                            _handleInstantEmojiSelect(item.emoji);
                          } else {
                            setState(() {
                              if (isPicked) {
                                _selectedEmoji = '';
                              } else {
                                _selectedEmoji = item.emoji;
                                _isChecked = true;
                              }
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isPicked
                                ? habitColor.withValues(
                                    alpha: isDark ? 0.35 : 0.2,
                                  )
                                : (isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard),
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(
                              color: isPicked
                                  ? habitColor
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              width: isPicked ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
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
}
