package com.latham.group.model;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;

import org.jivesoftware.smack.XMPPException;
import org.jivesoftware.smack.packet.Message;
import org.json.JSONException;

import android.util.Log;
import android.widget.Toast;

import com.latham.group.activities.ChatActivity;
import com.latham.group.utils.UserManager;
import com.quickblox.module.chat.QBChatRoom;
import com.quickblox.module.chat.QBChatService;
import com.quickblox.module.chat.listeners.ChatMessageListener;
import com.quickblox.module.chat.listeners.RoomListener;
import com.quickblox.module.chat.utils.QBChatUtils;
import com.quickblox.module.users.model.QBUser;

public class RoomChat implements Chat{

    public static final String EXTRA_ROOM_NAME = "name";
    public static final String EXTRA_ROOM_ACTION = "action";
    private static final String TAG = RoomChat.class.getSimpleName();
    private ChatActivity chatActivity;
    private QBChatRoom chatRoom;
    private ChatRoomListener chatRoomListener;
    private ChatRoomMessageListener chatRoomMessageListener;
    
    public static enum RoomAction {CREATE, JOIN}

    public RoomChat(ChatActivity chatActivity) {
        this.chatActivity = chatActivity;
        chatRoomListener = new ChatRoomListener();
        chatRoomMessageListener = new ChatRoomMessageListener();

        String chatRoomName = chatActivity.getIntent().getStringExtra(EXTRA_ROOM_NAME);
        RoomAction action = (RoomAction) chatActivity.getIntent().getSerializableExtra(EXTRA_ROOM_ACTION);

        switch (action) {
            case CREATE:
                create(chatRoomName);
                break;
            case JOIN:
                //join( ((App) chatActivity.getApplication()).getCurrentRoom());
            	join(chatRoomName);
                break;
        }
    }

    @Override
    public void sendMessage(String message) throws XMPPException {
        Log.d(TAG, "send message " + message);
    	if (chatRoom != null) {
            chatRoom.sendMessage(message);
        } else {
            Toast.makeText(chatActivity, "Join unsuccessful", Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void release() throws XMPPException {
        if (chatRoom != null) {
            QBChatService.getInstance().leaveRoom(chatRoom);
            chatRoom.removeMessageListener(chatRoomMessageListener);
        }
    }

    public void create(String roomName) {
        // Creates open & persistent room
        QBChatService.getInstance().createRoom(roomName, false, true, chatRoomListener);
    }

    public void join(QBChatRoom room) {
        QBChatService.getInstance().joinRoom(room, chatRoomListener);
    }
    
    public void join(String roomName) {
        QBChatService.getInstance().joinRoom(roomName, chatRoomListener);
    }
  
    private class ChatRoomListener implements RoomListener{

    	@Override
        public void onCreatedRoom(QBChatRoom room) {
            Log.d(TAG, "room was created");
            chatRoom = room;
            chatRoom.addMessageListener(chatRoomMessageListener);
        }

        @Override
        public void onJoinedRoom(QBChatRoom room) {
            Log.d(TAG, "joined to room");
            chatRoom = room;
            chatRoom.addMessageListener(chatRoomMessageListener);
        }

        @Override
        public void onError(String msg) {
            Log.d(TAG, "error joining to room");
        }
    	
    }
    
    private class ChatRoomMessageListener implements ChatMessageListener{

    	@Override
        public void processMessage(Message message) {
            Date time = QBChatUtils.parseTime(message);
            if (time == null) {
                time = Calendar.getInstance().getTime();
            }
            // Show message
            String sender = QBChatUtils.parseRoomOccupant(message.getFrom());
            QBUser user = null;
    		try {
    			user = UserManager.getInstance().getCurrentUser();
    		} catch (IOException e) {
    			e.printStackTrace();
    		} catch (JSONException e) {
    			e.printStackTrace();
    		}
            if (sender.equals(user.getLogin()) || sender.equals(user.getId().toString())) {
                chatActivity.showMessage(new ChatMessage(message.getBody(), "me", time, false));
            } else {
                chatActivity.showMessage(new ChatMessage(message.getBody(), sender, time, true));
            }
        }

        @Override
        public boolean accept(Message.Type messageType) {
            switch (messageType) {
                case groupchat:
                    return true;
                default:
                    return false;
            }
        }	
    }
}
