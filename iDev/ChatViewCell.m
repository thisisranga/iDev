//
//  ChatViewCell.m
//  iDev
//
//  Created by rnallave on 4/8/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import "ChatViewCell.h"

@implementation ChatViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self._message = [[UILabel alloc] init];
        [self.contentView addSubview:self._message];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) layoutSubviews {
    [super layoutSubviews];
    
    self._message.frame = CGRectMake(130,05,185,40);
    self._message.textColor = [UIColor whiteColor];
    self._message.backgroundColor = [UIColor greenColor];
    self._message.font = [UIFont fontWithName:@"Helvetica" size:18];
    self._message.lineBreakMode = YES;
    self._message.numberOfLines = 0;
    
}
@end
