//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

#if __has_include(<smkit_ui_flutter_plugin/SMKitUIFlutterPlugin.h>)
#import <smkit_ui_flutter_plugin/SMKitUIFlutterPlugin.h>
#else
@import smkit_ui_flutter_plugin;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
  [SMKitUIFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"SMKitUIFlutterPlugin"]];
}

@end
