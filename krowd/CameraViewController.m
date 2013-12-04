//
//  CameraViewController.m
//  krowd
//
//  Created by Julie Caccavo on 9/15/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()
{
    UIImagePickerController *pickerController;
    UIButton *flashButton;
}
@end

@implementation CameraViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    pickerController = [[UIImagePickerController alloc]init];
    pickerController.delegate = self;

}

- (void)viewDidAppear:(BOOL)animated{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self customizeCameraController];
        [self presentViewController:pickerController animated:NO completion:nil];
    }
    else{
        [self customizeCameraController];
        pickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.delegate = self;
        pickerController.showsCameraControls = NO;
        pickerController.allowsEditing = NO;
        pickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        [self presentViewController:pickerController animated:NO completion:nil];
    }
}


- (void)customizeCameraController{
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setFrame:CGRectMake(0, 8, 69, 32)];
    [flashButton setImage:[UIImage imageNamed:@"flashAutoButton.png"] forState:UIControlStateNormal];
    [flashButton addTarget:self action:@selector(setFlash) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *camDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [camDeviceButton setFrame:CGRectMake(0, 8, 39, 32)];
    [camDeviceButton setImage:[UIImage imageNamed:@"camDeviceButton.png"] forState:UIControlStateNormal];
    [camDeviceButton addTarget:self action:@selector(camDevice) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *items1=[NSArray arrayWithObjects:
                     [[UIBarButtonItem alloc] initWithCustomView:flashButton],
                     [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                     [[UIBarButtonItem alloc] initWithCustomView:camDeviceButton],
                     nil];
    
    if (screenSize.height > 480.0f) {
        /*Do iPhone 5 stuff here.*/
        UIToolbar *toolBar1=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [toolBar1 setBackgroundImage:[UIImage imageNamed:@"cameraBar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [toolBar1 setItems:items1];
        [pickerController.view addSubview:toolBar1];
        
        UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePhotoButton setFrame:CGRectMake(0, 0, 85, 86)];
        [takePhotoButton setImage:[UIImage imageNamed:@"takePhotoButton.png"] forState:UIControlStateNormal];
        [takePhotoButton addTarget:self action:@selector(shootPicture) forControlEvents:UIControlEventTouchUpInside];
        
        UIToolbar *toolBar2=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 400, 320, 168)];
        [toolBar2 setBackgroundImage:[UIImage imageNamed:@"cameraBar2.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        toolBar2.barStyle = UIBarStyleBlack;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor blackColor];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelPicture) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSArray *items2=[NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithCustomView:cancelButton],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithCustomView:takePhotoButton],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                         nil];
        [toolBar2 setItems:items2];
        [pickerController.view addSubview:toolBar2];
    } else {
        /*Do iPhone Classic stuff here.*/
        UIToolbar *toolBar1=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [toolBar1 setBackgroundImage:[UIImage imageNamed:@"cameraBar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [toolBar1 setItems:items1];
        [pickerController.view addSubview:toolBar1];
        
        UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePhotoButton setFrame:CGRectMake(0, 0, 45, 46)];
        [takePhotoButton setImage:[UIImage imageNamed:@"takePhotoButton.png"] forState:UIControlStateNormal];
        [takePhotoButton addTarget:self action:@selector(shootPicture) forControlEvents:UIControlEventTouchUpInside];
        
        UIToolbar *toolBar2=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 412, 320, 68)];
        [toolBar2 setBackgroundImage:[UIImage imageNamed:@"cameraBar4.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        toolBar2.barStyle = UIBarStyleBlack;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(0, 0, 55, 20)];
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        cancelButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:14.0];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor blackColor];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelPicture) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSArray *items2=[NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithCustomView:cancelButton],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithCustomView:takePhotoButton],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                         nil];
        [toolBar2 setItems:items2];
        [pickerController.view addSubview:toolBar2];
    }
    
}

- (void)shootPicture{
    [pickerController takePicture];
}

- (void)cancelPicture{
    [self.delegate didCancelPhoto];
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)setFlash{
    if (pickerController.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
        pickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [flashButton setImage:[UIImage imageNamed:@"flashOffButton.png"] forState:UIControlStateNormal];
    }
    else if (pickerController.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff){
        pickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [flashButton setImage:[UIImage imageNamed:@"flashOnButton.png"] forState:UIControlStateNormal];
    }
    else{
        pickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        [flashButton setImage:[UIImage imageNamed:@"flashAutoButton.png"] forState:UIControlStateNormal];
    }
    
}

- (void)camDevice{
    if(pickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
        pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else{
        pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    
}

#pragma mark - Image picker delegate methods


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.delegate didTakePhoto:info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:NO completion:nil];
}

/*
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
        [self dismissViewControllerAnimated:NO completion:^{
           // [self.delegate didCancelPhoto];
        }];
    [self.navigationController popToRootViewControllerAnimated:NO];

}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
