//
//  cfLocationViewController.h
//  Crowsflight
//
//  Created by Che-Wei Wang on 5/4/13.
//  Copyright (c) 2013 CW&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWTAppDelegate.h"

#import "CWTArrow.h"
#import "CWTDot.h"

#import <AudioToolbox/AudioToolbox.h>

#import "BTLECentralViewController.h"
#import "BTLEPeripheralViewController.h"

@interface CWTLocationViewController : UIViewController<UIScrollViewDelegate>{
    CWTAppDelegate* dele;
    int bearingAccuracy;

}

@property (nonatomic,strong)  UIImageView *arrowImage;

@property (nonatomic,strong)  CWTArrow* arrow;
@property (nonatomic,strong)  CWTDot* pushProgress;
@property (nonatomic,strong)  CWTDot* refreshProgress;


@property (nonatomic,strong)  UIImageView *satSearchImage;
@property (nonatomic,strong)  UIImageView *dnArrow;
@property (nonatomic,strong)  UIImageView *north;
@property (nonatomic,strong) UIButton *heart;


@property (nonatomic,strong)  UILabel *mainMessage;
@property (nonatomic,strong)  UILabel *distanceText;
@property (nonatomic,strong)  UILabel *pushMessage;

@property (nonatomic,strong) IBOutlet UILabel *accuracyText;
@property (nonatomic,strong) IBOutlet UILabel *unitText;
@property (nonatomic,strong) IBOutlet  UILabel *displayText;

//@property (nonatomic)   UITextField *nameField;


@property (nonatomic) NSInteger page;
@property (nonatomic) float dlat;
@property (nonatomic) float dlng;
@property (nonatomic) float locBearing;
@property (nonatomic) float distance;
@property (nonatomic) float maxDistance;
@property (nonatomic) float progress;
@property (nonatomic) float spin;
@property (nonatomic) float angle;
@property (nonatomic) float lastAngle;
@property (nonatomic) int spread;
@property (nonatomic) int lastSpread;
@property (nonatomic) int myUserNumber;
@property (nonatomic) int numPhrases;

@property (nonatomic) BOOL spinning;
@property (nonatomic) BOOL hasAnother;


@property (nonatomic) NSString * otherUserVendorIDString;
@property (nonatomic) NSString * otherUsername;

@property (nonatomic)  NSDate *launchTime;
@property (nonatomic,strong) IBOutlet  UILabel *time;


-(void)loadLocation;

-(void)updateDistanceWithLatLng: (float)duration;
- (void)rotateArc:(NSTimeInterval)duration  degrees:(CGFloat)degrees;

- (void)updateHeading;
- (void)rotateCompass:(NSTimeInterval)duration  degrees:(CGFloat)degrees;

-(void)showHideInfo: (float)duration;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *mainView;

@property (nonatomic,strong) BTLECentralViewController *BTLECentral;
@property (nonatomic,strong) BTLEPeripheralViewController *BTLPeripheral;


@end
