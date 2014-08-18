//
//  MCMainViewController.h
//  MassChat
//
//  Created by Yu Sun on 8/10/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatController.h"

@interface MCMainViewController : UIViewController <ChatControllerDelegate, QBActionStatusDelegate>
{
    BOOL _animated;
    CGFloat _offset;
}

@property (strong, nonatomic) ChatController * chatController;

@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) QBChatRoom *chatRoom;

@end
