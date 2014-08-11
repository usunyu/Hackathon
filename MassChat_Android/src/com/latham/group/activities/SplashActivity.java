package com.latham.group.activities;

import org.jivesoftware.smack.ConnectionListener;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.latham.group.App;
import com.latham.group.R;
import com.latham.group.model.RoomChat;
import com.quickblox.core.QBCallback;
import com.quickblox.core.QBSettings;
import com.quickblox.core.result.Result;
import com.quickblox.module.auth.QBAuth;
import com.quickblox.module.chat.QBChatService;
import com.quickblox.module.users.QBUsers;
import com.quickblox.module.users.model.QBUser;

public class SplashActivity extends Activity implements QBCallback {

	private static final int AUTHENTICATION_REQUEST = 1;

	// Tao
	private static final String APP_ID = "13189";
	private static final String AUTH_KEY = "zeyZY5C45PY58er";
	private static final String AUTH_SECRET = "O69NzHYX7LDfJHJ";

	public static final String USER_LOGIN = "mark";
	public static final String USER_PASSWORD = "12345678";

	// Sun
	// private static final String APP_ID = "13062";
	// private static final String AUTH_KEY = "N6zpRQgnHaZTXHq";
	// private static final String AUTH_SECRET = "nWfKxY9XnwBTY6p";

	private ProgressBar progressBar;
	private ConnectionListener connectionListener;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);

		progressBar = (ProgressBar) findViewById(R.id.progressBar);

		QBSettings.getInstance().fastConfigInit(APP_ID, AUTH_KEY, AUTH_SECRET);
		QBAuth.createSession(this);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == RESULT_OK) {
			connectionListener = new ChatConnectionListener();
			QBChatService.getInstance().addConnectionListener(connectionListener);
			enterRoom();
			finish();
		}
	}
	
	private void enterRoom(){
		Intent intent = new Intent(this, ChatActivity.class);
		Bundle bundle = createChatBundle(getRoomName(), false);
        intent.putExtras(bundle);
        startActivity(intent);	
		//((App)getApplication()).setCurrentRoom();
	}
	
	public static void start(Context context, Bundle bundle) {
        
    }
	
	private String getRoomName(){
		return "FB";
	}

	public void showAuthenticateDialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("Authorize first");
		builder.setItems(new String[] { "Login", "Register" }, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case 0:
					Intent intent = new Intent(SplashActivity.this, LoginActivity.class);
					startActivityForResult(intent, AUTHENTICATION_REQUEST);
					break;
				case 1:
					intent = new Intent(SplashActivity.this, RegistrationActivity.class);
					startActivityForResult(intent, AUTHENTICATION_REQUEST);
					break;
				}
			}
		});
		builder.show();
	}

	@Override
	public void onComplete(Result result) {
		progressBar.setVisibility(View.GONE);
		
		if (result.isSuccess()) {
			QBUser user = ((App) getApplication()).getQbUser();
			if (user == null) {
				Log.d("Tao", "First time login");
				showAuthenticateDialog();
			}else{ 
				Log.d("Tao", "Already login");
				QBUsers.signIn(user, this);
				enterRoom();
				finish();
			}
		} else {
			AlertDialog.Builder dialog = new AlertDialog.Builder(this);
			dialog.setMessage(
					"Error(s) occurred. Look into DDMS log for details, " + "please. Errors: " + result.getErrors())
					.create().show();
		}
	}

	private Bundle createChatBundle(String roomName, boolean createChat) {
		Bundle bundle = new Bundle();
		bundle.putSerializable(ChatActivity.EXTRA_MODE, ChatActivity.Mode.GROUP);
		bundle.putString(RoomChat.EXTRA_ROOM_NAME, roomName);
		if (createChat) {
			bundle.putSerializable(RoomChat.EXTRA_ROOM_ACTION, RoomChat.RoomAction.CREATE);
		} else {
			bundle.putSerializable(RoomChat.EXTRA_ROOM_ACTION, RoomChat.RoomAction.JOIN);
		}
		return bundle;
	}

	@Override
	public void onComplete(Result result, Object context) {
	}

	private class ChatConnectionListener implements ConnectionListener {

		@Override
		public void connectionClosed() {
			showToast("connectionClosed");
		}

		@Override
		public void connectionClosedOnError(Exception e) {
			showToast("connectionClosed on error" + e.getLocalizedMessage());
		}

		@Override
		public void reconnectingIn(int i) {

		}

		@Override
		public void reconnectionSuccessful() {

		}

		@Override
		public void reconnectionFailed(Exception e) {

		}
	}

	private void showToast(final String msg) {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Toast.makeText(SplashActivity.this, msg, Toast.LENGTH_LONG).show();
			}
		});
	}
}