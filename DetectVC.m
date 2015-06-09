//
//  DetectVC.m
//  ReKognition Demo
//
//  Created by Leppard on 6/7/15.
//  Copyright (c) 2015 Orbeus Inc. All rights reserved.
//

#import "DetectVC.h"
#import "FaceThumbnailCropper.h"
#import "ReKognitionSDK.h"
#import "ReKognitionResults.h"
#import <QuartzCore/QuartzCore.h>
#import "FaceThumbnailCropper.h"
#import "UIImageRotationFixer.h"
#import "APIKey+Secret.h"

@implementation DetectVC


-(void)viewDidLoad{

    [super viewDidLoad];
    self.VCMain = [[VCMain alloc]init];
    self.VCMain.blunoManager = [DFBlunoManager sharedInstance];
    self.VCMain.blunoManager.delegate = self.VCMain;
    self.VCMain.aryDevices = [[NSMutableArray alloc] init];
    [self.VCMain.aryDevices removeAllObjects];
    [self.VCMain.tbDevices reloadData];
    [self.VCMain.SearchIndicator startAnimating];
    
    [self.VCMain.blunoManager scan];
    
    self.imageDetectView.contentMode = UIViewContentModeScaleAspectFit;
    self.label.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    self.imageDetectView.image = self.image;
}

-(IBAction)startDetect{
    [self.VCMain connect];
    if(self.imageDetectView.image){
        
        // image x, y, width, height
        float image_x, image_y, image_width, image_height;
        if(self.imageDetectView.image.size.width/self.imageDetectView.image.size.height > self.imageDetectView.frame.size.width/self.imageDetectView.frame.size.height){
            image_width = self.imageDetectView.frame.size.width;
            image_height = image_width/self.imageDetectView.image.size.width * self.imageDetectView.image.size.height;
            image_x = 0;
            image_y = (self.imageDetectView.frame.size.height - image_height)/2;
            
            
            if (self.imageDetectView.image.size.width > 2600){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Image too large" message:@"Max image size is 3000 px" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                 
            }
        }else if(self.imageDetectView.image.size.width/self.imageDetectView.image.size.height < self.imageDetectView.frame.size.width/self.imageDetectView.frame.size.height)
        {
            image_height = self.imageDetectView.frame.size.height;
            image_width = image_height/self.imageDetectView.image.size.height * self.imageDetectView.image.size.width;
            image_y = 0;
            image_x = (self.imageDetectView.frame.size.width - image_width)/2;
            if (self.imageDetectView.image.size.width > 2600){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Image too large" message:@"Max image size is 3000 px" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                 
            }
            
        }else{
            image_x = 0;
            image_y = 0;
            image_width = self.imageDetectView.frame.size.width;
            image_height = self.imageDetectView.frame.size.height;
            if (self.imageDetectView.image.size.width > 2600){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Image too large" message:@"Max image size is 3000 px" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                 
            }
        }
        
        
        [ self.activityIndicator startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        dispatch_async(queue, ^{
            
            FaceThumbnailCropper *cropper = [[FaceThumbnailCropper alloc] init];
//            UIImage *cropped = [cropper cropFaceThumbnailsInUIImage:self.imageDetectView.image];
            RKFaceDetectResults* detectResults;
            ReKognitionSDK *sdk = [[ReKognitionSDK alloc] initWithAPIKey:API_KEY APISecret:API_SECRET];
//            if (cropped) {
//                detectResults = [sdk RKFaceDetect:cropped jobs:FaceDetectAge|FaceDetectEyeClosed|FaceDetectPart|FaceDetectGender|FaceDetectGlass];
//                [cropper correctFaceDetectResult:detectResults];
//            } else {
                detectResults = [sdk RKFaceDetect:self.imageDetectView.image jobs:FaceDetectAge|FaceDetectEyeClosed|FaceDetectPart|FaceDetectGender|FaceDetectGlass];
//            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [ self.activityIndicator stopAnimating];
                 self.label.hidden = NO;
                
                NSArray * list = detectResults.faceDetectOrALikeItems;
//                 self.label.text = @"Face detection: \n";
                
                int face_no = 0;
                for(int i = 0; i < [list count]; i++){
                    FaceDetectItem *item = list[i];
                    if (item.confidence > 0.1){
                        
                        face_no = face_no + 1;
                        
                        float gender = item.sex;
                        float glasses = item.wear_glasses;
                        float confidence = item.confidence;
                        float eye_closed = item.eye_closed;
                        float age = item.age;
                        
                        
//                         self.label.text = [ self.label.text stringByAppendingFormat:@"Face %d -- ", i+1];
//                         self.label.text = [ self.label.text stringByAppendingFormat:@"confidence: %04.2f; ",
//                                          confidence];
//                         self.label.text = [ self.label.text stringByAppendingFormat:@"glass: %04.2f; ",
//                                          glasses];
//                         self.label.text = [ self.label.text stringByAppendingFormat:@"age: %04.2f; ",
//                                          age];
//                         self.label.text = [ self.label.text stringByAppendingFormat:@"eye_closed: %04.2f.\n",
//                                          eye_closed];
                        self.labelEyeClose.text = [NSString stringWithFormat:@"%.2f",eye_closed*100];
                        self.labelEyeClose.text = [self.labelEyeClose.text stringByAppendingString:@"%"];
                        if(eye_closed*100 > 90.0){
                            [self.VCMain writeMsg:@"1"];
                        }
                        else{
                            [self.VCMain writeMsg:@"0"];
                        }
                        
                        CGFloat resize_scale = image_width/self.imageDetectView.image.size.width;

                        float x = item.boundingbox.origin.x;
                        float y = item.boundingbox.origin.y;
                        float width = item.boundingbox.size.width;
                        float height = item.boundingbox.size.height;
                        
                        CALayer *layer = [CALayer new];
                        layer.borderWidth = 2.0f;
                        [layer setCornerRadius:5.0f*resize_scale];
                        [layer setFrame:CGRectMake(x*resize_scale + image_x,
                                                   y*resize_scale + image_y,
                                                   width*resize_scale,
                                                   height*resize_scale)];
                        layer.borderColor = [[UIColor colorWithRed:(1-gender) green:0.0 blue:gender alpha:1] CGColor];
                        
                        // returned right eye position
                        float radius = width*resize_scale/40;
                        float eye_right_x = item.eye_right.x;
                        float eye_right_y = item.eye_right.y;
                        CALayer *eye_right_layer = [CALayer new];
                        [eye_right_layer setCornerRadius:radius];
                        eye_right_layer.backgroundColor = layer.borderColor;
                        [eye_right_layer setFrame:CGRectMake((eye_right_x - x)*resize_scale - radius,
                                                             (eye_right_y - y)*resize_scale - radius,
                                                             radius * 2, radius * 2)];
                        
                        // returned left eye position
                        float eye_left_x = item.eye_left.x;
                        float eye_left_y = item.eye_left.y;
                        CALayer *eye_left_layer = [CALayer new];
                        eye_left_layer.backgroundColor = layer.borderColor;
                        [eye_left_layer setCornerRadius:radius];
                        [eye_left_layer setFrame:CGRectMake((eye_left_x - x)*resize_scale - radius,
                                                            (eye_left_y - y)*resize_scale - radius,
                                                            radius * 2, radius * 2)];
                        
                        // returned nose position
                        float nose_x = item.nose.x;
                        float nose_y = item.nose.y;
                        CALayer *nose_layer = [CALayer new];
                        nose_layer.backgroundColor = layer.borderColor;
                        [nose_layer setCornerRadius: radius];
                        [nose_layer setFrame:CGRectMake((nose_x - x)*resize_scale - radius,
                                                        (nose_y - y)*resize_scale - radius,
                                                        radius * 2,
                                                        radius * 2)];
                        
                        // returned right mouth position
                        float mouth_right_x = item.mouth_r.x;
                        float mouth_right_y = item.mouth_r.y;
                        CALayer *mouth_right_layer = [CALayer new];
                        mouth_right_layer.backgroundColor = layer.borderColor;
                        [mouth_right_layer setCornerRadius: radius];
                        [mouth_right_layer setFrame:CGRectMake((mouth_right_x - x)*resize_scale - radius,
                                                               (mouth_right_y - y)*resize_scale - radius,
                                                               radius * 2,
                                                               radius * 2)];
                        
                        
                        // returned left mouth position
                        float mounth_left_x = item.mouth_l.x;
                        float mounth_left_y = item.mouth_l.y;
                        CALayer *mouth_left_layer = [CALayer new];
                        mouth_left_layer.backgroundColor = layer.borderColor;
                        [mouth_left_layer setCornerRadius:radius];
                        [mouth_left_layer setFrame:CGRectMake((mounth_left_x - x)*resize_scale - radius,
                                                              (mounth_left_y - y)*resize_scale - radius,
                                                              radius * 2,
                                                              radius * 2)];
                        
                        
                        
                        
                        CATextLayer *label = [[CATextLayer alloc] init];
                        [label setFontSize:16];
                        [label setString:[@"" stringByAppendingFormat:@"%d", i+1]];
                        [label setAlignmentMode:kCAAlignmentCenter];
                        [label setForegroundColor:layer.borderColor];
                        [label setFrame:CGRectMake(0, layer.bounds.size.height, layer.frame.size.width, 25)];
                        
                        
                        [layer addSublayer:eye_left_layer];
                        [layer addSublayer:eye_right_layer];
//                        [layer addSublayer:nose_layer];
                        [layer addSublayer:mouth_left_layer];
                        [layer addSublayer:mouth_right_layer];
//                        [layer addSublayer:label];
                        
                        [self.imageDetectView.layer addSublayer:layer];
                    }
                    
                }
                
                if(face_no > 2){
                     self.label.frame = CGRectMake( self.label.frame.origin.x,  self.label.frame.origin.y,  self.label.frame.size.width,  self.label.frame.size.height + 45 * (face_no-2));
                     self.label.numberOfLines = 1 + face_no * 2;
                }
            });
        });
        
    }
}

- (IBAction)tryAgain:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Image from..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Image Gallary", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 0.80;

    [actionSheet showInView:self.view];
    [self.VCMain writeMsg:@"0"];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex)
    {
            self.label.hidden = YES;
        case 0:
        {
#if TARGET_IPHONE_SIMULATOR
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Saw Them" message:@"Camera not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
#elif TARGET_OS_IPHONE
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            //picker.allowsEditing = YES;
            [self presentViewController:picker animated:YES completion:nil];
            [self clearRecognitionResults];
#endif
        }
            break;
        case 1:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            [self clearRecognitionResults];
        }
            break;
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *rawImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageDetectView.image =[UIImageRotationFixer fixOrientation:rawImage];
    self.labelEyeClose.text = @"0%";
    [picker dismissViewControllerAnimated:YES completion:nil];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}


-(void) clearRecognitionResults{
    self.label.hidden = YES;
    if(self.imageDetectView.layer.sublayers)
        [self.imageDetectView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
}

@end
