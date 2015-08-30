//
//  ViewController.m
//  Aragog
//
//  Created by Vasja Pavlov on 06/08/15.
//  Copyright (c) 2015 Vasja Pavlov. All rights reserved.
//

#import "ViewController.h"
@import GoogleMaps;

@implementation ViewController {
    __weak IBOutlet GMSMapView *mapView_;
    __weak IBOutlet UITextField *addressInput;
    BOOL autoCompleteLocked;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    autoCompleteLocked = false;
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
//    mapView_ = [GMSMapView mapWithFrame:mapContainerView.frame camera:camera];
    [mapView_ setCamera:camera];
    
    mapView_.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
    

}

- (void)handleAutocompleteForString:(NSString *)inputString {

    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    
    if (autoCompleteLocked) {
        NSLog(@"Error");
    }
    autoCompleteLocked = true;
    __weak ViewController *weakSelf = self;
    [ [GMSPlacesClient sharedClient] autocompleteQuery:inputString
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                [weakSelf parsePredictions:results];
                            }];
}

- (void)parsePredictions:(NSArray *)predictions
{
    NSMutableArray *places = [NSMutableArray new];
    for (GMSAutocompletePrediction* result in predictions) {
        [places addObject:result.attributedFullText];
    }
    autoCompleteLocked = false;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (newString.length >= 3 && !autoCompleteLocked) {
        [self handleAutocompleteForString:newString];
    }
    return true;
}

@end
