//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
void set_default_handler(NSString *url_scheme, NSString *handler);
NSMutableDictionary* get_http_handlers(void);
