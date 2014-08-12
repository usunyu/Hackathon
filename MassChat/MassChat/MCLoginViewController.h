//
//  MCLoginViewController.h
//  MassChat
//
//  Created by Yu Sun on 8/10/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCLoginViewController : UIViewController <QBActionStatusDelegate>

@property NSString *username;
@property NSString *password;

@property (strong, nonatomic) IBOutlet UILabel *tapLabel;
@property (strong, nonatomic) IBOutlet UILabel *loadLabel;

@end
