/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTPullToRefreshViewComponentView.h"

#import <react/renderer/components/rncore/ComponentDescriptors.h>
#import <react/renderer/components/rncore/EventEmitters.h>
#import <react/renderer/components/rncore/Props.h>
#import <react/renderer/components/rncore/RCTComponentViewHelpers.h>

#import <React/RCTConversions.h>
#import <React/RCTRefreshableProtocol.h>
#import <React/RCTScrollViewComponentView.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface RCTPullToRefreshViewComponentView () <RCTPullToRefreshViewViewProtocol, RCTRefreshableProtocol>
@end

@implementation RCTPullToRefreshViewComponentView {
#if !TARGET_OS_OSX // TODO(macOS GH#774)
  UIRefreshControl *_refreshControl;
#endif // TODO(macOS GH#774)
  RCTScrollViewComponentView *__weak _scrollViewComponentView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    // This view is not designed to be visible, it only serves UIViewController-like purpose managing
    // attaching and detaching of a pull-to-refresh view to a scroll view.
    // The pull-to-refresh view is not a subview of this view.
    self.hidden = YES;

    static auto const defaultProps = std::make_shared<PullToRefreshViewProps const>();
    _props = defaultProps;

#if !TARGET_OS_OSX // TODO(macOS GH#774)
    _refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self
                        action:@selector(handleUIControlEventValueChanged)
              forControlEvents:UIControlEventValueChanged];
#endif // TODO(macOS GH#774)
  }

  return self;
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<PullToRefreshViewComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  auto const &oldConcreteProps = *std::static_pointer_cast<PullToRefreshViewProps const>(_props);
  auto const &newConcreteProps = *std::static_pointer_cast<PullToRefreshViewProps const>(props);

  if (newConcreteProps.refreshing != oldConcreteProps.refreshing) {
#if !TARGET_OS_OSX // TODO(macOS GH#774)
    if (newConcreteProps.refreshing) {
      [_refreshControl beginRefreshing];
    } else {
      [_refreshControl endRefreshing];
    }
#endif // TODO(macOS GH#774)
  }

  BOOL needsUpdateTitle = NO;

  if (newConcreteProps.title != oldConcreteProps.title) {
    needsUpdateTitle = YES;
  }

  if (newConcreteProps.titleColor != oldConcreteProps.titleColor) {
    needsUpdateTitle = YES;
  }

  if (needsUpdateTitle) {
    [self _updateTitle];
  }

  [super updateProps:props oldProps:oldProps];
}

#pragma mark -

- (void)handleUIControlEventValueChanged
{
  std::static_pointer_cast<PullToRefreshViewEventEmitter const>(_eventEmitter)->onRefresh({});
}

- (void)_updateTitle
{
  auto const &concreteProps = *std::static_pointer_cast<PullToRefreshViewProps const>(_props);

  if (concreteProps.title.empty()) {
#if !TARGET_OS_OSX // TODO(macOS GH#774)
    _refreshControl.attributedTitle = nil;
#endif // TODO(macOS GH#774)
    return;
  }

  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  if (concreteProps.titleColor) {
    attributes[NSForegroundColorAttributeName] = RCTUIColorFromSharedColor(concreteProps.titleColor);
  }

#if !TARGET_OS_OSX // TODO(macOS GH#774)
  _refreshControl.attributedTitle =
      [[NSAttributedString alloc] initWithString:RCTNSStringFromString(concreteProps.title) attributes:attributes];
#endif // TODO(macOS GH#774)
}

#pragma mark - Attaching & Detaching

- (void)didMoveToWindow
{
  if (self.window) {
    [self _attach];
  } else {
    [self _detach];
  }
}

- (void)_attach
{
  if (_scrollViewComponentView) {
    [self _detach];
  }

  _scrollViewComponentView = [RCTScrollViewComponentView findScrollViewComponentViewForView:self];
  if (!_scrollViewComponentView) {
    return;
  }

#if !TARGET_OS_OSX // TODO(macOS GH#774)
  if (@available(macOS 13.0, *)) {
    _scrollViewComponentView.scrollView.refreshControl = _refreshControl;
  }
#endif // TODO(macOS GH#774)
}

- (void)_detach
{
  if (!_scrollViewComponentView) {
    return;
  }

  // iOS requires to end refreshing before unmounting.
#if !TARGET_OS_OSX // TODO(macOS GH#774)
  [_refreshControl endRefreshing];

  if (@available(macOS 13.0, *)) {
    _scrollViewComponentView.scrollView.refreshControl = nil;
  }
#endif // TODO(macOS GH#774)
  _scrollViewComponentView = nil;
}

#pragma mark - Native commands

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args
{
  RCTPullToRefreshViewHandleCommand(self, commandName, args);
}

- (void)setNativeRefreshing:(BOOL)refreshing
{
#if !TARGET_OS_OSX // TODO(macOS GH#774)
  if (refreshing) {
    [_refreshControl beginRefreshing];
  } else {
    [_refreshControl endRefreshing];
  }
#endif // TODO(macOS GH#774)
}

#pragma mark - RCTRefreshableProtocol

- (void)setRefreshing:(BOOL)refreshing
{
  [self setNativeRefreshing:refreshing];
}

#pragma mark -

- (NSString *)componentViewName_DO_NOT_USE_THIS_IS_BROKEN
{
  return @"RefreshControl";
}

@end

Class<RCTComponentViewProtocol> RCTPullToRefreshViewCls(void)
{
  return RCTPullToRefreshViewComponentView.class;
}
