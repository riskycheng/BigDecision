#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.chengjian.BigDecision.BigDecision";

/// The "AppPrimary" asset catalog color resource.
static NSString * const ACColorNameAppPrimary AC_SWIFT_PRIVATE = @"AppPrimary";

/// The "AppSecondary" asset catalog color resource.
static NSString * const ACColorNameAppSecondary AC_SWIFT_PRIVATE = @"AppSecondary";

#undef AC_SWIFT_PRIVATE
