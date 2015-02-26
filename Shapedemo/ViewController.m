#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:pan];
    
    self.path = [[UIBezierPath alloc] init];
    
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.fillColor = [UIColor darkGrayColor].CGColor;
    [self.view.layer insertSublayer:self.shapeLayer atIndex:0];
}

- (void)panned:(UIPanGestureRecognizer *)pan
{
    CGFloat h = CGRectGetHeight(self.view.frame);
    CGFloat innerControlPointRatio = 0.7;
    CGFloat outerControlPointDistance = 75;
    
    // we want the y position of touch, but we only want the translation along x axis for smooth start
    CGPoint touchPoint = CGPointMake([pan translationInView:pan.view].x, [pan locationInView:pan.view].y);
    
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        [self.path removeAllPoints];
        [self.path moveToPoint:CGPointZero];
        
        // Next two methods are the key part.
        // Bezier curve from top left edge to touch point,
        [self.path addCurveToPoint:CGPointMake(touchPoint.x, touchPoint.y)
                controlPoint1:CGPointMake(0, touchPoint.y * innerControlPointRatio)
                controlPoint2:CGPointMake(touchPoint.x, touchPoint.y - outerControlPointDistance)];
        // and from touch point to bottom left edge.
        [self.path addCurveToPoint:CGPointMake(0, h)
                controlPoint1:CGPointMake(touchPoint.x, touchPoint.y + outerControlPointDistance)
                controlPoint2:CGPointMake(0, touchPoint.y + (h - touchPoint.y) * (1.0 - innerControlPointRatio))];
        [self.path closePath];
    }
    else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        // When pan is done animate the shape layer back to line.
        // However, for path morphing animation to work, it needs
        // to have same number of points as current path (3).
        // Also, this could be done with just 2 lines, but we'll
        // use curves insted for morphing to be smoother.
        // With lines there would be a pointy tip visible towards end.
        [self.path removeAllPoints];
        [self.path moveToPoint:CGPointZero];
        [self.path addCurveToPoint:CGPointMake(0, touchPoint.y)
                     controlPoint1:CGPointMake(0, touchPoint.y * innerControlPointRatio)
                     controlPoint2:CGPointMake(0, touchPoint.y - outerControlPointDistance)];
        [self.path addCurveToPoint:CGPointMake(0, h)
                     controlPoint1:CGPointMake(0, touchPoint.y + outerControlPointDistance)
                     controlPoint2:CGPointMake(0, touchPoint.y + (h - touchPoint.y) * (1.0 - innerControlPointRatio))];
        [self.path closePath];
        
        CABasicAnimation *returnAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        returnAnimation.toValue = self.path;
        [self.shapeLayer addAnimation:returnAnimation forKey:nil];
    }
    
    // Give the new path to shape layer to draw.
    // Disable actions to prevent implicit animation
    // since we are drawing every frame manually during
    // pan, or adding explicit animation when pan ends.
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.shapeLayer.path = self.path.CGPath;
    [CATransaction commit];
}

@end