//
//  MainViewController.h
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol SideViewControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;

@required
- (void)movePanel;
- (void)movePanelToOriginalPosition;

@end

@protocol MainViewControllerDelegate <NSObject>

@required
- (void)userChoseOtherViewController;
- (void)userChoseThisViewController;

@end

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
{
    id<MainViewControllerDelegate> delegate;
    BOOL showingNavMenu;
}
@property (nonatomic, strong) id<MainViewControllerDelegate> delegate;
@property BOOL showingNavMenu;
@end
