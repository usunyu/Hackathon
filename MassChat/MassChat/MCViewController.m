//
//  MCViewController.m
//  MassChat
//
//  Created by Yu Sun on 8/9/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCViewController.h"

@interface MCViewController ()

@end

@implementation MCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.tapLabel.textAlignment = NSTextAlignmentCenter;
    self.tapLabel.center = self.view.center;
    self.tapLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.tapLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tapLabel.layer.borderWidth = 2.0;
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void) autoLogin
{
    // Log in auto for test
    _username = @"Sunny";
    _password = @"12345678";
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = _username;
    extendedAuthRequest.userPassword = _password;
    
	[QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
}

- (void) handleTap:(UITapGestureRecognizer *)tap {
    
    if (!self.chatController) self.chatController = [ChatController new];
    self.chatController.delegate = self;
    
    self.tapLabel.text = @"Loading ...";
    [self autoLogin];
}

#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result {
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        // Success result
        if(result.success){
            
            QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
            
            // Save current user
            QBUUser *currentUser = [QBUUser user];
            currentUser.ID = res.session.userID;
            currentUser.login = _username;
            currentUser.password = _password;
            //
            [[MCLocalStorageService shared] setCurrentUser:currentUser];
            
            // Login to QuickBlox Chat
            [[MCChatService instance] loginWithUser:currentUser completionBlock:^{
                // show chat view
                [self presentViewController:self.chatController animated:YES completion:nil];
                
                if([MCLocalStorageService shared].currentUser != nil){
                    // get dialogs
                    [QBChat dialogsWithExtendedRequest:nil delegate:self];
                }
                
                // Set chat notifications
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:) name:kNotificationDidReceiveNewMessageFromRoom object:nil];
            }];
            
        }else{
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }else if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;

        NSArray *dialogs = pagedResult.dialogs;
        
        // Just set first demo chat room now !!!!
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
            [[MCChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
                // joined
                NSLog(@"joined");
            }];
        }
        
        // get messages history
        [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
    }else if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        [self addHistoryMessages:res.messages];
    }
}

- (void) addHistoryMessages:(NSArray *)messages {
    for (int i = 0; i < [messages count]; i++) {
        NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
        QBChatHistoryMessage *historyMessage = messages[i];
        [message setObject:historyMessage.text  forKey:kMessageContent];
        [message setObject:historyMessage.datetime  forKey:kMessageTimestamp];
        [message setObject:[NSString stringWithFormat:@"%d", (int)historyMessage.senderID] forKey:@"sentByUserId"];
        [self.chatController addNewMessage:message];
    }
}

#pragma mark Chat Notifications

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    QBChatMessage *QBMessage = notification.userInfo[kMessage];
    NSString *roomJID = notification.userInfo[kRoomJID];
    if(![self.chatRoom.JID isEqualToString:roomJID]){
        return;
    }
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    [message setObject:QBMessage.text  forKey:kMessageContent];
    [message setObject:QBMessage.datetime  forKey:kMessageTimestamp];
    [message setObject:[NSString stringWithFormat:@"%d", (int)QBMessage.senderID] forKey:@"sentByUserId"];
    [self.chatController addNewMessage:message];
}


#pragma mark CHAT CONTROLLER DELEGATE

- (void) chatController:(ChatController *)chatController didSendMessage:(NSMutableDictionary *)message {
    /*
    // Messages come prepackaged with the contents of the message and a timestamp in milliseconds
    NSLog(@"Message Contents: %@", message[kMessageContent]);
    NSLog(@"Timestamp: %@", message[kMessageTimestamp]);
    
    // Evaluate or add to the message here for example, if we wanted to assign the current userId:
    message[@"sentByUserId"] = [NSString stringWithFormat:@"%d", (int)[MCLocalStorageService shared].currentUser.ID];
    
    // Must add message to controller for it to show
    [self.chatController addNewMessage:message];
    */
     
    // create a QB message
    QBChatMessage *QBMessage = [[QBChatMessage alloc] init];
    QBMessage.text = message[kMessageContent];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [QBMessage setCustomParameters:params];
    
    // dialogType should be QBChatDialogTypePublicGroup
    if (self.dialog.type == QBChatDialogTypePublicGroup) {
        [[MCChatService instance] sendMessage:QBMessage toRoom:self.chatRoom];
    }
}


/* Optional
 - (void) closeChatController {
 [chatController dismissViewControllerAnimated:YES completion:^{
 [chatController removeFromParentViewController];
 chatController = nil;
 }];
 }
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
