//
//  MSCollectionViewCalendarLayout+TouchTime.h
//  Pods
//
//  Created by Ilya Golovanov on 12/12/13.
//
//
//  Example

//  UILongPressGestureRecognizer* longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
//  [self.collectionView addGestureRecognizer:longGesture];
//
//  return self;
//  }
//
//  -(void)onLongPress:(UILongPressGestureRecognizer*)recoginzer {
//    if (recoginzer.state == UIGestureRecognizerStateBegan) {
//      NSDate* date = [_collectionViewCalendarLayout timeForPoint:[recoginzer locationInView:self.collectionView]];
//      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"touchTime" message:[date descriptionWithLocale:[NSLocale currentLocale] ]
//                                                     delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
//      [alert show];
//    }
//  }

#import "MSCollectionViewCalendarLayout.h"

@interface MSCollectionViewCalendarLayout (TouchTime)

-(NSDate*)timeForPoint:(CGPoint)point; 
@end
