
#import "FloatingCamera.h"

@interface FloatingCamera ()
{
    NSNotificationCenter *notCenter;
    UITapGestureRecognizer *tapGesture;
    BOOL tap;
}

@end

@implementation FloatingCamera

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        notCenter = [NSNotificationCenter defaultCenter];
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCamera:)];
        [self addGestureRecognizer:tapGesture];
        tap = YES;
        
        self.backgroundColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0) blue:(150/255.0) alpha:0.4];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        self.imageView.backgroundColor = [UIColor colorWithRed:(225/255.0) green:(225/255.0) blue:(225/255.0) alpha:0.6];
        self.imageView.image = [UIImage imageNamed:@"Krowd_Nav_Cam@2x.png"];
        [self addSubview:self.imageView];
        self.userInteractionEnabled = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.imageView.image = [UIImage imageNamed:@"camera1.png"];
    [notCenter postNotificationName:@"CameraMovingNotification" object:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.imageView.image = [UIImage imageNamed:@"Krowd_Nav_Cam@2x.png"];
    [notCenter postNotificationName:@"CameraNotMovingNotification" object:self];
    tap = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.imageView.image = [UIImage imageNamed:@"Krowd_Nav_Cam@2x.png"];
    [notCenter postNotificationName:@"CameraNotMovingNotification" object:self];
    tap = YES;
}

- (IBAction)goToCamera:(UITapGestureRecognizer *)sender{
    if (tap) {
        [notCenter postNotificationName:@"goToCameraNotification" object:self];
    }

}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    tap = NO;
    
    if (location.x > ((int)self.superview.frame.size.width - (int)self.frame.size.width) + (int)self.frame.size.width/2) {
        location.x = (int)self.superview.frame.size.width - (int)self.frame.size.width + (int)self.frame.size.width/2;
    }
    else if (location.x < (int)self.frame.size.width/2){
        location.x = (int)self.frame.size.width/2;
    }
    
    /*if (location.y > ((int)self.superview.frame.size.height - (int)self.frame.size.height) + (int)self.frame.size.height/2) {
        location.y = (int)self.superview.frame.size.height - (int)self.frame.size.height + (int)self.frame.size.height/2;
    }
    else if (location.y <  + (int)self.frame.size.height/2){
        location.y = (int)self.frame.size.height/2;
    }*/
    if (location.y < (int)self.frame.size.height/3) {
        location.y = (int)self.frame.size.height/2;
    }
    
    self.center = CGPointMake(location.x, location.y);

}

@end
