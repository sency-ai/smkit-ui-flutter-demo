# Migration Guide to v1.2.8

> **Note**: For the latest version (v1.3.0) with Android 16 compatibility, see the [Migration Guide v1.3.0](migration-v1.3.0.md). For v1.2.9 with Android 15 16KB page size compatibility, see the [Migration Guide v1.2.9](migration-v1.2.9.md).

This guide helps you migrate your existing `flutter_smkit_ui` implementation to version 1.2.8.

## ⚠️ Breaking Changes in v1.2.8

### 1. Preference Setter Methods (CRITICAL)

**Old Way (v1.2.7 and earlier) - CAUSES HANGING:**
```dart
// ❌ This will cause your app to hang
await _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
await _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
await _smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
```

**New Way (v1.2.8+) - FIRE-AND-FORGET:**
```dart
// ✅ These are now fire-and-forget calls
_smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
_smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
_smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
```

## Migration Steps

### Step 1: Update pubspec.yaml

```yaml
dependencies:
  flutter_smkit_ui: ^1.2.8  # Update from your current version
```

### Step 2: Remove await from Setters

Find all instances of preference setters and remove `await`:

```dart
// Before
void startCustomizedAssessment() async {
  await _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
  // ... rest of the method
}

// After
void startCustomizedAssessment() async {
  _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
  // ... rest of the method
}
```

### Step 3: Update User Data Format

Enhanced user data support in v1.2.8:

```dart
// Old format (still supported)
userData: {
  'gender': 'Male',
  'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
}

// New format (recommended)
userData: {
  'gender': 'male',        // or 'female', 'idle' (case-insensitive)
  'birthday': DateTime(1990, 1, 1).millisecondsSinceEpoch,
  'email': 'user@example.com',  // optional field
}
```

### Step 4: Improve Error Handling

v1.2.8 provides better error handling patterns:

```dart
// Old error handling
onHandle: (status) {
  if (status.operation == SMKitOperation.error) {
    debugPrint('Error: ${status.data}');
  }
}

// New error handling (recommended)
onHandle: (status) {
  if (status.operation == SMKitOperation.error) {
    String errorMessage = _parseErrorMessage(status.data);
    debugPrint('❌ Assessment error: $errorMessage');
    _showErrorDialog(errorMessage);
  }
}

String _parseErrorMessage(dynamic errorData) {
  if (errorData == null) return 'Unknown error occurred';
  
  try {
    if (errorData is String) {
      if (errorData.startsWith('{"error"')) {
        final match = RegExp(r'"error":\s*"([^"]*)"').firstMatch(errorData);
        if (match != null) {
          return match.group(1) ?? errorData;
        }
      }
      return errorData;
    } else if (errorData is SMKitError) {
      return errorData.error ?? 'SMKit error occurred';
    }
    return errorData.toString();
  } catch (e) {
    return 'Error parsing response: $errorData';
  }
}
```

### Step 5: Add Configuration Checks

v1.2.8 examples include better configuration validation:

```dart
void startAssessment() async {
  // Check if plugin is configured before starting
  if (!isConfigured) {
    _showErrorDialog('Plugin not configured yet. Please wait for configuration to complete.');
    return;
  }
  
  // Proceed with assessment...
}
```

## Benefits of v1.2.8

1. **Eliminates timeout issues** during assessment startup
2. **Faster assessment initialization** with fire-and-forget setters
3. **More reliable custom assessment launching**
4. **Better error handling and debugging** capabilities
5. **Enhanced user data support** with optional fields
6. **Improved platform compatibility** (Android/iOS alignment)

## Common Migration Issues

### Issue 1: App Hangs During Assessment Startup

**Cause**: Using `await` with preference setters
**Solution**: Remove `await` from all setter calls

### Issue 2: Gender Field Not Working

**Cause**: Case sensitivity or incorrect format
**Solution**: Use lowercase values: 'male', 'female', or 'idle'

### Issue 3: Configuration Errors

**Cause**: Starting assessments before plugin is configured
**Solution**: Add configuration checks before starting assessments

## Testing Your Migration

1. **Remove all `await` keywords** from preference setters
2. **Update user data format** to include email (optional)
3. **Add configuration validation** before starting assessments
4. **Test error scenarios** to ensure proper error handling
5. **Verify all assessment types work** (fitness, body360, strength, cardio, custom)

## Example: Complete Migration

### Before (v1.2.7)
```dart
void startCustomizedAssessment() async {
  var assessment = await getDemoAssessment();
  await _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
  await _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
  
  _smkitUiFlutterPlugin.startCustomizedAssessment(
    assessment: assessment,
    onHandle: (status) {
      if (status.operation == SMKitOperation.error) {
        debugPrint('Error: ${status.data}');
      }
    },
  );
}
```

### After (v1.2.8)
```dart
void startCustomizedAssessment() async {
  try {
    // Check configuration
    if (!isConfigured) {
      _showErrorDialog('Plugin not configured yet. Please wait for configuration to complete.');
      return;
    }

    var assessment = await getDemoAssessment();
    
    // Fire-and-forget setters (no await)
    _smkitUiFlutterPlugin.setSessionLanguage(language: SMKitLanguage.english);
    _smkitUiFlutterPlugin.setCounterPreferences(counterPreferences: SMKitCounterPreferences.perfectOnly);
    _smkitUiFlutterPlugin.setEndExercisePreferences(endExercisePrefernces: SMKitEndExercisePreferences.targetBased);
    
    _smkitUiFlutterPlugin.startCustomizedAssessment(
      assessment: assessment,
      onHandle: (status) {
        if (status.operation == SMKitOperation.error) {
          String errorMessage = _parseErrorMessage(status.data);
          debugPrint('❌ Assessment error: $errorMessage');
          _showErrorDialog(errorMessage);
        } else if (status.operation == SMKitOperation.assessmentSummaryData && status.data != null) {
          final result = status.data as SMKitAssessmentSummaryData;
          // Handle success...
        }
      },
    );
  } catch (e) {
    debugPrint('❌ Exception in startCustomizedAssessment: $e');
    _showErrorDialog('Exception occurred: $e');
  }
}
```

## Need Help?

If you encounter issues during migration:

1. Check the [Error Handling Guide](errorHandling.md)
2. Review the updated [API documentation](../README.md)
3. Compare your code with the example implementation
4. Ensure all `await` keywords are removed from preference setters