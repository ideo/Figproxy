// This code originally started from github user kerma's "default browser" code to set the browser
// code can be found here:
// https://github.com/kerma/defaultbrowser

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
//#import <ApplicationServices/ApplicationServices.h>

NSString* app_name_from_bundle_id(NSString *app_bundle_id);
NSMutableDictionary* get_http_handlers(void);
NSString* get_current_http_handler(void);
void set_default_handler(NSString *url_scheme, NSString *handler);

NSString* app_name_from_bundle_id(NSString *app_bundle_id) {
    return [[[app_bundle_id componentsSeparatedByString:@"."] lastObject] lowercaseString];
}

NSMutableDictionary* get_http_handlers() {
    // Create an NSWorkspace instance
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    // Get URLs for applications that can open HTTP URLs
    NSArray<NSURL *> *appURLs = [workspace URLsForApplicationsToOpenURL:[NSURL URLWithString:@"http://"]];
    // Create a dictionary to hold the app names and bundle identifiers
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSURL *url in appURLs) {
        // Get the bundle identifier from the application URL
        NSBundle *appBundle = [NSBundle bundleWithURL:url];
        NSString *bundleID = appBundle.bundleIdentifier;
        // If you still want to use app names derived from bundle IDs
        if (bundleID) {
            NSString *appName = app_name_from_bundle_id(bundleID);
            dict[appName] = bundleID;
        }
    }
    return dict;
}

NSString* get_current_http_handler() {
    // Create an NSWorkspace instance
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    // Create a dummy HTTP URL to use for fetching the default handler
    NSURL *httpURL = [NSURL URLWithString:@"http://"];
    // Get the URL of the default application set to handle HTTP URLs
    NSURL *appURL = [workspace URLForApplicationToOpenURL:httpURL];
    // Extract the bundle identifier from the application URL
    NSString *handler = [NSBundle bundleWithURL:appURL].bundleIdentifier;
    // Use the helper function to format the application name from its bundle ID
    return app_name_from_bundle_id(handler);
}

void set_default_handler(NSString *url_scheme, NSString *handler) {
    LSSetDefaultHandlerForURLScheme(
        (__bridge CFStringRef) url_scheme,
        (__bridge CFStringRef) handler
    );
}

//Old Application Services Code
/*
NSMutableDictionary* get_http_handlers() {
    NSArray *handlers =
      (__bridge NSArray *) LSCopyAllHandlersForURLScheme(
        (__bridge CFStringRef) @"http"
      );

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (int i = 0; i < [handlers count]; i++) {
        NSString *handler = [handlers objectAtIndex:i];
        dict[app_name_from_bundle_id(handler)] = handler;
    }

    return dict;
}

NSString* get_current_http_handler() {
    NSString *handler =
        (__bridge NSString *) LSCopyDefaultHandlerForURLScheme(
            (__bridge CFStringRef) @"http"
        );

    return app_name_from_bundle_id(handler);
}
 */
