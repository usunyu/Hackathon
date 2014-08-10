//
//  MCViewController.h
//  MassChat
//
//  Created by Yu Sun on 8/9/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatController.h"

@interface MCViewController : UIViewController <ChatControllerDelegate, QBActionStatusDelegate>

@property NSString *username;
@property NSString *password;

@property (strong, nonatomic) IBOutlet UILabel *tapLabel;
@property (strong, nonatomic) ChatController * chatController;

@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) QBChatRoom *chatRoom;

@end
