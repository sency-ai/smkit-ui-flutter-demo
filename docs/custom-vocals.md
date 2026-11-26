# Choosing voices and section title vocals

This guide covers `flutter_smkit_ui` 1.6.2 (iOS SMKitUI 2.7.3, Android 1.9.9).
It explains how to pick the male or female voice, and how to make the SDK
announce a section title such as "Classic Set 1" before an exercise.

## Pick the voices

The SDK speaks with two voices, which it reads when you call `configure`:

| `SMKitConfig` field | Speaks | Default | Values |
|---|---|---|---|
| `voiceFeedbackVoice` | Coaching: exercise intros, counting, form feedback, rest, section titles | `SMKitVoice.male1` | `male1`, `female1` |
| `mobilityFlowVoice` | Mobility Flow sessions | `SMKitVoice.female1` | `male1`, `female1` |

Set both with `setConfig` **before** `configure`:

```dart
final smkit = SmkitUiFlutterPlugin();

await smkit.setConfig(
  config: const SMKitConfig(
    voiceFeedbackVoice: SMKitVoice.female1, // coaching in the female voice
    mobilityFlowVoice: SMKitVoice.male1, // Mobility Flow in the male voice
  ),
);
await smkit.configure(key: apiKey);
```

- Both fields work the same on iOS and Android.
- The voices are fixed for as long as the SDK stays configured. To switch
  voices, call `setConfig` with the new values and then `configure` again,
  before the next session.
- Voice audio is downloaded after `configure`. Give the device a network
  connection for the first session in each voice.
- **English** and **Mandarin** (`SMKitLanguage.mandarin`) have both voices.
  For Mandarin, only the first startup and phone-placement prompts ship inside
  the SDK; every other prompt comes from the downloaded voice.
- **Hebrew** has one recording for each option: `male1` for coaching and
  `female1` for Mobility Flow. Keep the defaults when you configure Hebrew.

In this demo, open **UI Settings** and use **Feedback voice** and
**Mobility flow voice**, then tap **Reconfigure SDK**.

### English voices recorded

Sency has recorded these English voices. The SDK currently selects only
`male_1` and `female_1` (`SMKitVoice.male1` and `SMKitVoice.female1`); the
others are not selectable yet.

| Main (coaching) | Mobility Flow |
|---|---|
| Male_1 | Male_1
| Male_2 | Male_2 |
| Male_3 | Male_3 |
| Male_4 | |
| Male_5 | |
| Female_1 | Female_1 |
| Female_2 | Female_2 |
| Female_3 | Female_3 |
| Female_4 | |
| Female_5 | |

## Announce section titles

Give an exercise a section title through `displayContext`. The SDK shows the
title and, when it knows a voice recording for it, speaks it before that
exercise starts. Put the title on the first exercise of each section only.

```dart
final firstSquatSet = SMKitExercise(
  detector: 'SquatRegular',
  prettyName: 'Squats',
  totalSeconds: 60,
  targetReps: 13,
  uiElements: const [SMKitUIElement.timer, SMKitUIElement.repsCounter],
  displayContext: const SMKitExerciseDisplayContext(
    sectionTitle: 'Classic Set 1',
  ),
);
```

### Titles the SDK speaks on its own

Matching ignores case, spaces, hyphens and accents, so `'Warm-Up'`,
`'WARM UP'` and `'warmup'` all play the same recording.

| Title | iOS 2.7.3 | Android 1.9.9 |
|---|---|---|
| Warm Up, Bonus Warm Up, Workout, Main Set, Bonus Set | ✅ | ✅ |
| Strength, Cardio, Core, Mobility, Upper Body, Lower Body | ✅ | ✅ |
| Release, Cool Down, Recovery, Finisher | ✅ | ✅ |
| Round 1 – Round 25 | ✅ | ✅ |
| Classic Set 1 – Classic Set 4 | ✅ | ❌ |
| Superset 1 – Superset 2 | ✅ | ❌ |
| Giant Set 1 – Giant Set 3 | ✅ | ❌ |

Any other title is shown on screen without a voice, unless you name a
recording yourself (next section).

### Choose a different recording

`sectionTitleSoundKey` names the recording to play. It is tried first; if it
can't be found, the SDK falls back to the standard recording for the title.

```dart
const SMKitExerciseDisplayContext(
  sectionTitle: 'Classic Set 1',
  // Android 1.9.9 has no standard Classic Set voice, so name it explicitly.
  sectionTitleSoundKey: 'SectionTitleClassicSet1',
);
```

The standard recordings are named `SectionTitle` followed by the title without
spaces: `SectionTitleMainSet`, `SectionTitleRound3`, `SectionTitleClassicSet2`,
and so on.

What the key can point to differs by platform:

| Key | iOS | Android |
|---|---|---|
| A Sency recording name, such as `SectionTitleMainSet` | ✅ | ✅ |
| Your own MP3 as an absolute file path on the device | ✅ | ❌ |
| Your own MP3 as an `https://` URL | ✅ (played from the network) | ❌ |

On Android the key must name a recording Sency delivers. Your own MP3 files are
not supported there.

### Keep a title silent

Set `playsTitleSound: false` to show the title without speaking it:

```dart
const SMKitExerciseDisplayContext(
  sectionTitle: 'Main Set',
  playsTitleSound: false,
);
```

## Rest vocals

A rest is an exercise with the `Rest` detector. Each rest plays its intro and
then one praise, which the SDK picks at random each time:

| Recording | Says |
|---|---|
| `Restintro` (the default intro) | "Rest." |
| `RestGuidanceintro` | "Rest. Take a moment to breathe and recover." |
| `RestPraise1` | "Great job! Enjoy your well-deserved break." |
| `RestPraise2` | "Take a deep breath and relax. You're doing excellent." |
| `RestPraise3` | "Recovery is key. Relax and recharge your energy." |
| `RestPraise4` | "Awesome work so far! Stay loose and ready for the next round." |
| `RestPraise5` | "Breathe in, breathe out. You've earned this moment of calm." |

The intro is not random, so every rest opens with "Rest." unless you choose
another intro with `exerciseIntro`:

```dart
SMKitExercise(
  detector: 'Rest',
  prettyName: 'Rest',
  totalSeconds: 30,
  exerciseIntro: 'RestGuidanceintro',
  uiElements: const [SMKitUIElement.timer],
  scoringParams: ScoringParams(type: ScoringType.time, scoreFactor: 0),
);
```

## Example: rounds in this demo

**Rounds (warm-up + 2 rounds)** on the home screen builds a session the way the
Jinni app builds its sessions. See `DemoPresets.rounds()` in
[`lib/demo_presets.dart`](../lib/demo_presets.dart).

| # | Exercise | Length | Target reps | Section title |
|---|---|---|---|---|
| 1 | Standing Side Bend Right | 20 s | – | Warm Up |
| 2 | Standing Side Bend Left | 20 s | – | |
| 3 | Squats | 60 s | 13 | Round 1 |
| 4 | Rest | 20 s | – | |
| 5 | Push-ups | 60 s | 11 | |
| 6 | Rest | 30 s | – | |
| 7 | Squats | 60 s | 12 | Round 2 |
| 8 | Rest | 40 s | – | |
| 9 | Push-ups | 60 s | 11 | |

- **Titles:** Warm Up, Round 1 and Round 2 are standard titles on both iOS and
  Android, so no `sectionTitleSoundKey` is needed.
- **Warm-up:** each side bend is held for Jinni's default stretch hold, 20 s.
- **Target reps** use Jinni's formula. Take the medium-level reps per minute
  (Squats 16, Push-ups 14), multiply by 80% in round 1 and 75% in round 2,
  round, and use at least 6.
- **Hitting the target** is announced by the SDK
  (`playTargetRepsCompletionVoice: true`). The timer keeps showing time, not
  rep progress (`targetRepsTimerDisplayMode: 'timeProgress'`).
- **Rests** follow every work set except the last, so the session ends on the
  final set. Each one picks `Restintro` or `RestGuidanceintro` at random.
