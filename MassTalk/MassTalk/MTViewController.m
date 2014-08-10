//
//  MTViewController.m
//  MassTalk
//
//  Created by Yu Sun on 8/6/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MTViewController.h"
#import "MTTableViewCell.h"

@implementation MTViewController

#pragma mark
#pragma mark ViewController lyfe cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.messages = [NSMutableArray array];
    
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([MTLocalStorageService shared].currentUser != nil){
        // get dialogs
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
    }
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:) name:NotificationDidReceiveNewMessageFromRoom object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show log in
        [self.navigationController performSegueWithIdentifier:kShowLoginViewControllerSegue sender:nil];
    });
}

#pragma mark -
#pragma mark QBActionStatusDelegate
// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        
        // Just set first chat room now !!!!
        self.dialog = dialogs[0];
        
        // Get dialogs users
        PagedRequest *pagedRequest = [PagedRequest request];
        pagedRequest.perPage = 100;
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBUsers usersWithIDs:[[dialogsUsersIDs allObjects] componentsJoinedByString:@","] pagedRequest:pagedRequest delegate:self];
        
        // Set title
        self.title = self.dialog.name;
        
        // Join room
        if(self.dialog.type != QBChatDialogTypePrivate){
            self.chatRoom = [self.dialog chatRoom];
            [[MTTalkServices instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
                // joined
                NSLog(@"joined");
            }];
        }
        
        // get messages history
        [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
    }else if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {    // login success
        QBUUserPagedResult *res = (QBUUserPagedResult *)result;
        [MTLocalStorageService shared].users = res.users;
        
//        if (!_chatController) _chatController = [ChatController new];
//        _chatController.delegate = self;
//        _chatController.chatTitle = @"Simple Chat";
//        _chatController.opponentImg = [UIImage imageNamed:@"tempUser.png"];
//        [self presentViewController:_chatController animated:YES completion:nil];
        
    }else if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *messages = res.messages;
        [self.messages addObjectsFromArray:[messages mutableCopy]];
        //
        [self.messagesTableView reloadData];
    }
}


#pragma mark
#pragma mark Actions

- (IBAction)sendMessage:(id)sender
{
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = self.messageTextField.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    // dialogType should be QBChatDialogTypePublicGroup
    if (self.dialog.type == QBChatDialogTypePublicGroup) {
        [[MTTalkServices instance] sendMessage:message toRoom:self.chatRoom];
    }

    // Clean text field
    [self.messageTextField setText:nil];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TalkMessageCellIdentifier = @"TalkMessageCellIdentifier";
    
    MTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TalkMessageCellIdentifier];
    if(cell == nil){
        cell = [[MTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TalkMessageCellIdentifier];
    }
    
    QBChatAbstractMessage *message = self.messages[indexPath.row];
    //
    [cell configureCellWithMessage:message];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatAbstractMessage *chatMessage = [self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [MTTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}

#pragma mark
#pragma mark Chat Notifications

// maybe delegate here
int checker = 0;

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    if (checker == 1) {
        checker = 0;
        return;
    }
    else {
        checker = 1;
    }
    
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomJID = notification.userInfo[kRoomJID];
    
    if(![self.chatRoom.JID isEqualToString:roomJID]){
        return;
    }
    
    // save message
    [self.messages addObject:message];
    
    // Reload table
    [self.messagesTableView reloadData];
    if(self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
		self.messageTextField.transform = CGAffineTransformMakeTranslation(0, -430);
        self.sendMessageButton.transform = CGAffineTransformMakeTranslation(0, -430);
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  self.messagesTableView.frame.size.height-219);
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
		self.messageTextField.transform = CGAffineTransformIdentity;
        self.sendMessageButton.transform = CGAffineTransformIdentity;
        self.messagesTableView.frame = CGRectMake(self.messagesTableView.frame.origin.x,
                                                  self.messagesTableView.frame.origin.y,
                                                  self.messagesTableView.frame.size.width,
                                                  self.messagesTableView.frame.size.height+219);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
