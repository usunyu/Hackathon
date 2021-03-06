//
//  QBChatHistoryMessageGetQuery.h
//  Quickblox
//
//  Created by Igor Alefirenko on 29/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//


@interface QBChatHistoryMessageGetQuery : QBChatQuery {
@private
    NSString *dialogID;
    NSMutableDictionary *getRequest;
    
}

- (id)initWithDialogID:(NSString *)_dialogID;
- (id)initWithDialogID:(NSString *)_dialogID extendedRequest:(NSMutableDictionary *)extendedRequest;

@end
