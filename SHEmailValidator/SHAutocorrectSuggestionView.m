//
//  SHAutocorrectSuggestionView.m
//  SHEmailValidator
//
//  Created by Eric Kuck on 10/12/13.
//  Copyright (c) 2013 SpotHero.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "SHAutocorrectSuggestionView.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kCornerRadius = 6;
static const NSInteger kArrowHeight = 12;
static const NSInteger kArrowWidth = 8;
static const NSInteger kMaxWidth = 240;
static const NSInteger kDismissButtonWidth = 30;

@interface SHAutocorrectSuggestionView ()

@property (nonatomic, strong) UIView *target;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *suggestionFont;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableAttributedString *attributedTitle;
@property (nonatomic, assign) CGRect textRect;

@end

@implementation SHAutocorrectSuggestionView

+ (instancetype)showFromView:(UIView *)target inContainerView:(UIView *)container title:(NSString *)title autocorrectSuggestion:(NSString *)suggestion withSetupBlock:(SetupBlock)block
{
    SHAutocorrectSuggestionView *suggestionView = [[SHAutocorrectSuggestionView alloc] initWithTarget:target title:title autocorrectSuggestion:suggestion withSetupBlock:block];
    
    [suggestionView showFromView:target inContainerView:container];
    return suggestionView;
}

+ (instancetype)showFromView:(UIView *)target title:(NSString *)title autocorrectSuggestion:(NSString *)suggestion withSetupBlock:(SetupBlock)block
{
    return [SHAutocorrectSuggestionView showFromView:target inContainerView:target.superview title:title autocorrectSuggestion:suggestion withSetupBlock:block];
}

+ (UIColor *)defaultFillColor
{
    return [UIColor blackColor];
}

+ (UIColor *)defaultTitleColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultSuggestionColor
{
    return [UIColor colorWithRed:0.5f green:0.5f blue:1.0f alpha:1.0f];
}

- (instancetype)initWithTarget:(UIView *)target title:(NSString *)title autocorrectSuggestion:(NSString *)suggestion withSetupBlock:(SetupBlock)block
{
    if ((self = [super init])) {
        self.title = title;
        self.suggestedText = suggestion;
        self.titleFont = [UIFont boldSystemFontOfSize:13];
        self.suggestionFont = [UIFont boldSystemFontOfSize:13];
        
        if (block) {
            block(self);
        }
        
        if (!self.fillColor) {
            self.fillColor = [SHAutocorrectSuggestionView defaultFillColor];
        }

        if (!self.strokeColor) {
            self.strokeColor = [UIColor clearColor];
        }
        
        if (!self.titleColor) {
            self.titleColor = [SHAutocorrectSuggestionView defaultTitleColor];
        }
        
        if (!self.suggestionColor) {
            self.suggestionColor = [SHAutocorrectSuggestionView defaultSuggestionColor];
        }

        self.attributedTitle = [[NSMutableAttributedString alloc] initWithString:[self.title stringByAppendingString:@"\n"]
                                                                      attributes:@{NSForegroundColorAttributeName: self.titleColor,
                                                                                   NSFontAttributeName: self.titleFont}];
        if (self.suggestedText) {
            [self.attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:self.suggestedText
                                                                                         attributes:@{NSForegroundColorAttributeName: self.suggestionColor,
                                                                                                      NSFontAttributeName: self.suggestionFont}]];
            [self.attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"?" attributes:@{NSForegroundColorAttributeName: self.titleColor,
                                                                                                                      NSFontAttributeName: self.titleFont}]];
        }

        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        [self.attributedTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.attributedTitle.length)];

        CGSize textSize = [self.attributedTitle boundingRectWithSize:CGSizeMake(kMaxWidth - kDismissButtonWidth, MAXFLOAT)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil].size;

        CGFloat width = textSize.width + kDismissButtonWidth + (kCornerRadius * 2) + self.strokeWidth;
        CGFloat height = textSize.height + kArrowHeight + (kCornerRadius * 2) + self.strokeWidth;
        CGFloat left = MAX(10, target.center.x - width / 2);
        CGFloat top = target.frame.origin.y - height + 4;

        self.frame = CGRectIntegral(CGRectMake(left, top, width, height));
        self.opaque = NO;

        self.textRect = CGRectMake((width - kDismissButtonWidth - textSize.width) / 2, kCornerRadius, textSize.width, textSize.height);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGSize contentSize = CGSizeMake(self.bounds.size.width - self.strokeWidth, self.bounds.size.height - kArrowHeight - self.strokeWidth);
    CGPoint arrowBottom = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - self.strokeWidth);

	CGMutablePathRef path = CGPathCreateMutable();
	
    CGPathMoveToPoint(path, NULL, arrowBottom.x, arrowBottom.y);
    CGPathAddLineToPoint(path, NULL, arrowBottom.x - kArrowWidth, arrowBottom.y - kArrowHeight);
    
    CGPathAddArcToPoint(path, NULL, self.strokeWidth, contentSize.height, self.strokeWidth, contentSize.height - kCornerRadius, kCornerRadius);
    CGPathAddArcToPoint(path, NULL, self.strokeWidth, self.strokeWidth, kCornerRadius, self.strokeWidth, kCornerRadius);
    CGPathAddArcToPoint(path, NULL, contentSize.width, self.strokeWidth, contentSize.width, kCornerRadius, kCornerRadius);
    CGPathAddArcToPoint(path, NULL, contentSize.width, contentSize.height, contentSize.width - kCornerRadius, contentSize.height, kCornerRadius);
    
    CGPathAddLineToPoint(path, NULL, arrowBottom.x + kArrowWidth, arrowBottom.y - kArrowHeight);
    
	CGPathCloseSubpath(path);

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);

    CGContextAddPath(context, path);
	CGContextClip(context);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextRestoreGState(context);

    CGFloat separatorX = contentSize.width - kDismissButtonWidth;
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, separatorX, self.strokeWidth);
    CGContextAddLineToPoint(context, separatorX, contentSize.height);
    CGContextStrokePath(context);
    
    CGFloat xSize = 12;
    CGContextSetLineWidth(context, 4);
    CGContextMoveToPoint(context, separatorX + (kDismissButtonWidth - xSize) / 2, (contentSize.height - xSize) / 2);
    CGContextAddLineToPoint(context, separatorX + (kDismissButtonWidth + xSize) / 2, (contentSize.height + xSize) / 2);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, separatorX + (kDismissButtonWidth - xSize) / 2, (contentSize.height + xSize) / 2);
    CGContextAddLineToPoint(context, separatorX + (kDismissButtonWidth + xSize) / 2, (contentSize.height - xSize) / 2);
    CGContextStrokePath(context);

    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextStrokePath(context);

	CGPathRelease(path);

    [self.attributedTitle drawInRect:self.textRect];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        
        CGSize viewSize = self.bounds.size;
        if (touchPoint.x >= 0 && touchPoint.x < viewSize.width && touchPoint.y >= 0 && touchPoint.y < viewSize.height - kArrowHeight) {
            if (touchPoint.x <= viewSize.width - kDismissButtonWidth && self.suggestedText) {
                [self.delegate suggestionView:self wasDismissedWithAccepted:YES];
                [self dismiss];
            } else {
                [self.delegate suggestionView:self wasDismissedWithAccepted:NO];
                [self dismiss];
            }
        }
    }
}

- (void)showFromView:(UIView *)target inContainerView:(UIView *)container
{
    self.target = target;
    
    self.alpha = 0.2;
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);

    // Frame is in target.superview coordinates
    self.frame = [target.superview convertRect:self.frame toView:container];
    [container addSubview:self];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 1;
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              self.transform = CGAffineTransformIdentity;
                                          }];
                     }];
}

- (void)updatePosition
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat left = MAX(10, self.target.center.x - width / 2);
    CGFloat top = self.target.frame.origin.y - height;
    
    self.frame = CGRectIntegral([self.target.superview convertRect:CGRectMake(left, top, width, height) toView:self.superview]);
}

- (void)dismiss
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              self.alpha = 0.2;
                                              self.transform = CGAffineTransformMakeScale(0.6, 0.6);
                                          }
                                          completion:^(BOOL innerFinished) {
                                              [self removeFromSuperview];
                                              self.target = nil;
                                          }];
                     }];
}

@end
