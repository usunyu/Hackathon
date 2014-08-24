package com.latham.group.activities;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.jivesoftware.smack.XMPPException;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.latham.group.App;
import com.latham.group.R;
import com.latham.group.adapters.ChatAdapter;
import com.latham.group.model.Chat;
import com.latham.group.model.ChatMessage;
import com.latham.group.model.RoomChat;
import com.latham.group.model.SingleChat;

public class ChatActivity extends Activity {

	public static final String EXTRA_MODE = "mode";
	private static final String TAG = ChatActivity.class.getSimpleName();
	private EditText messageEditText;
	private Mode mode = Mode.SINGLE;
	private Chat chat;
	private ChatAdapter adapter;
	private ListView messagesContainer;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_chat);

		initViews();
	}

	@Override
	public void onBackPressed() {
		try {
			chat.release();
		} catch (XMPPException e) {
			Log.e(TAG, "failed to release chat", e);
		}
		super.onBackPressed();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			Log.d(TAG, "Show Map");
			Intent intent = new Intent(this, MapActivity.class);
			startActivity(intent);
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	private void initViews() {
		messagesContainer = (ListView) findViewById(R.id.messagesContainer);
		messageEditText = (EditText) findViewById(R.id.messageEdit);
		Button sendButton = (Button) findViewById(R.id.chatSendButton);
		TextView meLabel = (TextView) findViewById(R.id.meLabel);
		TextView companionLabel = (TextView) findViewById(R.id.companionLabel);
		RelativeLayout container = (RelativeLayout) findViewById(R.id.container);

		adapter = new ChatAdapter(this, new ArrayList<ChatMessage>());
		messagesContainer.setAdapter(adapter);

		Intent intent = getIntent();
		mode = (Mode) intent.getSerializableExtra(EXTRA_MODE);
		switch (mode) {
		case GROUP:
			chat = new RoomChat(this);
			container.removeView(meLabel);
			container.removeView(companionLabel);
			break;
		case SINGLE:
			chat = new SingleChat(this);
			int userId = intent.getIntExtra(SingleChat.EXTRA_USER_ID, 0);
			companionLabel.setText("user(id" + userId + ")");
			restoreMessagesFromHistory(userId);
			break;
		}

		sendButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				String lastMsg = messageEditText.getText().toString();
				if (TextUtils.isEmpty(lastMsg)) {
					return;
				}

				messageEditText.setText("");
				try {
					chat.sendMessage(lastMsg);
				} catch (XMPPException e) {
					Log.e(TAG, "failed to send a message", e);
				}

				if (mode == Mode.SINGLE) {
					showMessage(new ChatMessage(lastMsg, Calendar.getInstance().getTime(), false));
				}
			}
		});
	}

	public void showMessage(ChatMessage message) {
		Log.d(TAG, "show message " + message.toString());
		saveMessageToHistory(message);
		adapter.add(message);
		adapter.notifyDataSetChanged();
		scrollDown();
	}

	public void showMessage(List<ChatMessage> messages) {
		adapter.add(messages);
		adapter.notifyDataSetChanged();
		scrollDown();
	}

	private void saveMessageToHistory(ChatMessage message) {
		if (mode == Mode.SINGLE) {
			((App) getApplication()).addMessage(getIntent().getIntExtra(SingleChat.EXTRA_USER_ID, 0), message);
		}
	}

	private void restoreMessagesFromHistory(int userId) {
		List<ChatMessage> messages = ((App) getApplication()).getMessages(userId);
		if (messages != null) {
			showMessage(messages);
		}
	}

	private void scrollDown() {
		messagesContainer.setSelection(messagesContainer.getCount() - 1);
	}

	public static enum Mode {
		SINGLE, GROUP
	}
}
