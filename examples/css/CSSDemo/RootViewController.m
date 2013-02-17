//
// Copyright 2011 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "RootViewController.h"

#import "AppDelegate.h"

static CGFloat squareSize = 200;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    NIStylesheetCache* stylesheetCache =
    [(AppDelegate *)[UIApplication sharedApplication].delegate stylesheetCache];
    NIStylesheet* stylesheet = [stylesheetCache stylesheetWithPath:@"root/root.css"];
    NIStylesheet* common = [stylesheetCache stylesheetWithPath:@"common.css"];
    _dom = [NIDOM domWithStylesheet:stylesheet andParentStyles:common];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stylesheetDidChange)
                                                 name:NIStylesheetDidChangeNotification
                                               object:stylesheet];
    self.title = @"Nimbus CSS Demo";
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _backgroundView = [[UIView alloc] init];
  CGSize boundsSize = self.view.bounds.size;
  _backgroundView.frame = CGRectMake(floorf((boundsSize.width - squareSize) / 2),
                                     floorf((boundsSize.height - squareSize) / 2),
                                     squareSize, squareSize);

  _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                        UIActivityIndicatorViewStyleWhiteLarge];
  [_activityIndicator sizeToFit];
  [_activityIndicator startAnimating];
  _activityIndicator.frame = CGRectMake(floorf((_backgroundView.bounds.size.width - _activityIndicator.bounds.size.width) / 2.f),
                                        10,
                                        _activityIndicator.bounds.size.width,
                                        _activityIndicator.bounds.size.height);

  _testLabel = [[UILabel alloc] init];
  _testLabel.text = @"Chameleon changes skins in real time.\n\nStop compiling.\nStart building.";
  _testLabel.frame = NIRectShift(_backgroundView.bounds, 0, CGRectGetMaxY(_activityIndicator.frame));
  
  _rightMiddleLabel = [[UILabel alloc] init];
  _rightMiddleLabel.text = @"Right Middle Label";

  _bottomLabel = [[UILabel alloc] init];
  _bottomLabel.text = @"Bottom Left Label";

  _button = [UIButton buttonWithType:UIButtonTypeCustom];
  _button.accessibilityLabel = @"TestButton";
  [_button addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
  [_button setTitle:@"Test Button" forState:UIControlStateNormal];

  [self.view addSubview:_button];
  [self.view addSubview:_rightMiddleLabel];
  [self.view addSubview:_backgroundView];
  [self.view addSubview:_bottomLabel];
  [_backgroundView addSubview:_activityIndicator];
  [_backgroundView addSubview:_testLabel];
  
  // Register our views with the DOM.
  [_dom registerView:self.view withCSSClass:@"background"];
  [_dom registerView:_activityIndicator];
  [_dom registerView:_testLabel];
  [_dom registerView:_backgroundView withCSSClass:@"noticeBox"];
  [_dom registerView:_rightMiddleLabel withCSSClass:@"rightMiddleLabel"];
  [_dom registerView:_bottomLabel withCSSClass:@"bottomLabel"];
  [_dom registerView:_button];
}

-(void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [_dom refresh];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [_dom unregisterAllViews];

  _activityIndicator = nil;
  _backgroundView = nil;
  _testLabel = nil;
}

-(void)buttonPress
{
  [_dom refresh];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stylesheetDidChange {
  [_dom refresh];
}

@end
