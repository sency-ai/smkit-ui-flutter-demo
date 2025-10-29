# Error Handling Guide

This guide explains how to properly handle errors in the `flutter_smkit_ui` plugin (v1.2.9).

## Error Types

The plugin can return various types of errors:

1. **Configuration Errors**: Plugin not properly configured with API key
2. **Assessment Errors**: Issues during assessment startup or execution
3. **Network Errors**: Connectivity issues during assessment
4. **Platform Errors**: Native SDK errors from Android/iOS

## Error Detection

Errors are detected through the `onHandle` callback when `status.operation == SMKitOperation.error`:

```dart
_smkitUiFlutterPlugin.startCustomizedAssessment(
  assessment: assessment,
  onHandle: (status) {
    if (status.operation == SMKitOperation.error) {
      // Handle error case
      String errorMessage = _parseErrorMessage(status.data);
      _showErrorDialog(errorMessage);
    }
    // Handle other operations...
  },
);
```

## Error Message Parsing

The error data can come in different formats:

```dart
String _parseErrorMessage(dynamic errorData) {
  if (errorData == null) return 'Unknown error occurred';
  
  try {
    if (errorData is String) {
      // Check if it's a JSON error
      if (errorData.startsWith('{"error"')) {
        final match = RegExp(r'"error":\s*"([^"]*)"').firstMatch(errorData);
        if (match != null) {
          return match.group(1) ?? errorData;
        }
      }
      return errorData;
    } else if (errorData is SMKitError) {
      final error = errorData as SMKitError;
      return error.error ?? 'SMKit error occurred';
    } else {
      return errorData.toString();
    }
  } catch (e) {
    return 'Error parsing response: $errorData';
  }
}
```

## Common Error Scenarios

### 1. Plugin Not Configured

```dart
void startAssessment() async {
  // Check configuration before starting
  if (!isConfigured) {
    _showErrorDialog('Plugin not configured yet. Please wait for configuration to complete.');
    return;
  }
  
  // Proceed with assessment...
}
```

### 2. Assessment Creation Issues

```dart
void startCustomizedAssessment() async {
  try {
    var assessment = await getDemoAssessment();
    debugPrint('✅ Assessment created: ${assessment.name}');
    
    // Start assessment...
  } catch (e, stackTrace) {
    debugPrint('❌ Exception in assessment creation: $e');
    _showErrorDialog('Failed to create assessment: $e');
  }
}
```

### 3. Runtime Assessment Errors

Monitor the callback for runtime errors during assessment execution:

```dart
onHandle: (status) {
  debugPrint('📊 Assessment status: ${status.operation}');
  
  if (status.operation == SMKitOperation.error) {
    String errorMessage = _parseErrorMessage(status.data);
    debugPrint('❌ Assessment error: $errorMessage');
    _showErrorDialog(errorMessage);
  }
}
```

## User-Friendly Error Dialog

Display errors to users in a clear, actionable way:

```dart
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Assessment Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('An error occurred:'),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
```

## Debugging Tips

### Enable Debug Logging

Use debug prints with emojis for better visibility:

```dart
debugPrint('🚀 Starting customized assessment...');
debugPrint('✅ Assessment created: ${assessment.name}');
debugPrint('❌ Assessment error: $errorMessage');
```

### Check Configuration State

Always verify the plugin is configured before starting assessments:

```dart
@override
void initState() {
  super.initState();
  initPlatformState();
  // Add listener for result handling...
}

Future<void> initPlatformState() async {
  if (!mounted) return;
  
  try {
    final result = await _smkitUiFlutterPlugin.configure(key: apiPublicKey);
    setState(() {
      isConfigured = result == true;
    });
    debugPrint(isConfigured ? '✅ Plugin configured' : '❌ Plugin configuration failed');
  } catch (e) {
    debugPrint('❌ Configuration error: $e');
    setState(() {
      isConfigured = false;
    });
  }
}
```

### Handle Network Issues

Network connectivity issues are common. Provide meaningful feedback:

```dart
if (errorMessage.toLowerCase().contains('network') || 
    errorMessage.toLowerCase().contains('connection')) {
  _showErrorDialog('Network connection issue. Please check your internet connection and try again.');
} else {
  _showErrorDialog(errorMessage);
}
```

## Best Practices

1. **Always check configuration state** before starting assessments
2. **Use try-catch blocks** around assessment creation and startup
3. **Parse error messages** for better user experience
4. **Provide actionable error messages** to users
5. **Log errors with context** for debugging
6. **Handle network connectivity issues** gracefully