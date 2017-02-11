//
//  Cache.h
//  AR-Quest
//
//  Created by Reto Marti on 13/05/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#ifndef Cache_h
#define Cache_h

#import <CoreLocation/CoreLocation.h>
#import "NamedObject.h"
#import <MapKit/MapKit.h>


@interface Cache : NamedObject <MKAnnotation> {
@protected
    CLLocationCoordinate2D gpsCoordinates;
}
// Location attributes
@property (atomic, strong) NSString* street;
@property (atomic) CLLocationCoordinate2D gpsCoordinates;

// Cache-group & target image
@property (atomic, strong) NSNumber* cacheGroupId;
@property (atomic, strong) NSString* targetImageName;

// MKAnnotation delegates
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, copy) NSString* title;
- (void) setCoordinate: (CLLocationCoordinate2D) newCoordinate;

@end


#endif /* Cache_h */
