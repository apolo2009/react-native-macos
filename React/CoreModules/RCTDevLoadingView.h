/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTBridgeModule.h>
#import <React/RCTDevLoadingViewProtocol.h>
// [macOS]
// Remove #import <UIKit/UIKit.h>

@interface RCTDevLoadingView : NSObject <RCTDevLoadingViewProtocol, RCTBridgeModule>
@end
