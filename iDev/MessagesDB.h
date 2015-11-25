//
//  MessagesDB.h
//  iDev
//
//  Created by Ranga Reddy Nallavelli on 8/15/15.
//  Copyright (c) 2015 Ranga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessagesDB : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * senderId;
@property (nonatomic) double timeStamp;
@property (nonatomic, retain) NSString * receipientId;

@end
