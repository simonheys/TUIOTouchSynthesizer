//
//  ViewController.h
//  TUIOTouchSynthesizer
//
//  Created by Simon Heys on 09/02/2013.
//  Copyright (c) 2013 Simon Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@end
