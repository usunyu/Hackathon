//
//  MCMainViewController.m
//  MassChat
//
//  Created by Yu Sun on 8/10/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCMainViewController.h"
#import "MCLoginViewController.h"
#import "MCMenuViewController.h"
#import "MCMapViewController.h"


@interface MCMainViewController ()

@end

@implementation MCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.title = @"Chat Everywhere";
    
    // Show login view
    MCLoginViewController *loginController = [[MCLoginViewController alloc] initWithNibName:nil bundle:nil];
    [MCPresentViewUtil present:self ViewController:loginController];
    
    // Disable interact
    self.chatController.view.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
    
    UIButton *_leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _leftBtn.frame = CGRectMake(4, 20, 30, 30);
    _leftBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [_leftBtn addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
    [_leftBtn setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:_leftBtn];
//    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(showLeft)];
    self.navigationItem.leftBarButtonItem = PP_AUTORELEASE(left);
    
    UIButton *_rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightBtn.frame = CGRectMake(4, 20, 33, 33);
    _rightBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [_rightBtn addTarget:self action:@selector(showRight) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn setImage:[UIImage imageNamed:@"map2.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
    //    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(showLeft)];
    self.navigationItem.rightBarButtonItem = PP_AUTORELEASE(right);
    
    _offset = 70;
    _animated = YES;
}

- (void)showLeft {
    MCMenuViewController *menuController = [[MCMenuViewController alloc] initWithStyle:UITableViewStylePlain];

    [self.revealSideViewController pushViewController:menuController onDirection:PPRevealSideDirectionLeft withOffset:_offset animated:_animated completion:^{ PPRSLog(@"This is the end!");
    }];
    
    PP_RELEASE(menuController);
}

- (void)showRight {
    MCMapViewController *mapController = [[MCMapViewController alloc] initWithNibName:nil bundle:nil];
    
    [MCPresentViewUtil present:self ViewController:mapController];
    
    PP_RELEASE(mapController);
}

- (void) viewWillAppear:(BOOL)animated
{
    // Add views here, or they may create problems when launching in landscape
    // Login to QuickBlox Chat
    QBUUser *currentUser = [MCLocalStorageService shared].currentUser;
    [[MCChatService instance] loginWithUser:currentUser completionBlock:^{
        if([MCLocalStorageService shared].currentUser != nil){
            // get dialogs
            [QBChat dialogsWithExtendedRequest:nil delegate:self];
        }
    }];
    
    // Show chat view
    if (!self.chatController) {
        self.chatController = [[ChatController alloc] initWithNibName:nil bundle:nil];
        self.chatController.delegate = self;
    }
    
    [self.view addSubview:self.chatController.view];
}

#pragma mark QBActionStatusDelegate
// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result {
    // QuickBlox session creation  result
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        
        NSArray *dialogs = pagedResult.dialogs;
        
        // Just set first demo chat room now !!!!
        self.dialog = dialogs[0];
        
        // Get dialogs users
        /*
        PagedRequest *pagedRequest = [PagedRequest request];
        pagedRequest.perPage = 100;
        //
        NSSet *dialogsUsersIDs = pagedResult.dialogsUsersIDs;
        //
        [QBUsers usersWithIDs:[[dialogsUsersIDs allObjects] componentsJoinedByString:@","] pagedRequest:pagedRequest delegate:self];
        */
         
        // Set title
//        self.title = self.dialog.name;
        
        /*
        if(self.dialog.type == QBChatDialogTypePrivate){
            QBUUser *recipient = [MCLocalStorageService shared].usersAsDictionary[@(self.dialog.recipientID)];
            self.title = recipient.login == nil ? recipient.email : recipient.login;
        }else{
            self.title = self.dialog.name;
        }
         */
        
        // Join room
        if(self.dialog.type != QBChatDialogTypePrivate){
            self.chatRoom = [self.dialog chatRoom];
            [[MCChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom *joinedChatRoom) {
                // joined
                NSLog(@"joined");
                
                // get messages history
                [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
            }];
        }
    }else if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        [self addHistoryMessages:res.messages];
        
        // Enable interact
        self.chatController.view.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        
        // Set chat notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:) name:kNotificationDidReceiveNewMessageFromRoom object:nil];
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
