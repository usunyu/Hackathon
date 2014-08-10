//
//  MTViewController.h
//  MassTalk
//
//  Created by Yu Sun on 8/6/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatController.h"

@interface MTViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (strong, nonatomic) IBOutlet UITableView *messagesTableView;

- (IBAction)sendMessage:(id)sender;

@property (nonatomic, strong) QBChatDialog *dialog;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) QBChatRoom *chatRoom;

@end
