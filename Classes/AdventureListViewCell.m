//
//  AdventureListViewCell.m
//  AR-Quest
//
//  Created by Reto Marti on 18.04.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "AdventureListViewCell.h"


@implementation AdventureListViewCell

@synthesize titleLabel, priceLabel, distanceLabel, statusLabel;


// Initialisation ------------------------------------------------------------------------

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
