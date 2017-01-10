//
//  PCloudSDKSwift.h
//  PCloudSDKSwift
//
//  Created by Todor Pitekov on 03/01/2017
//  Copyright © 2017 pCloud LTD. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for PCloudSDKSwift.
FOUNDATION_EXPORT double PCloudSDKSwiftVersionNumber;

//! Project version string for PCloudSDKSwift.
FOUNDATION_EXPORT const unsigned char PCloudSDKSwiftVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PCloudSDKSwift/PublicHeader.h>
