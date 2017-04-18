//
//  AdventureListViewCell.h
//  AR-Quest
//
//  Created by Reto Marti on 18.04.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface AdventureListViewCell : UITableViewCell

@property (unsafe_unretained, nonatomic) IBOutlet UILabel* titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel* priceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel* distanceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel* statusLabel;

@end
