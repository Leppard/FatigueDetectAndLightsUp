//
//  DetectVC.h
//  ReKognition Demo
//
//  Created by Leppard on 6/7/15.
//  Copyright (c) 2015 Orbeus Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCMain.h"

@interface DetectVC : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *labelEyeClose;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *imageDetectView;

@property (nonatomic, strong) VCMain *VCMain;

-(IBAction)startDetect;
- (IBAction)tryAgain:(id)sender;

@property (strong,nonatomic) UIImage *image;
@end
