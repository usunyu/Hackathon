package com.latham.group.activities;

import java.io.IOException;

import org.jivesoftware.smack.ConnectionListener;
import org.json.JSONException;

import android.app.Activity;
import android.app.AlertDialog;
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
import com.latham.group.model.User;
import com.latham.group.utils.UserManager;
import com.quickblox.core.QBCallback;
import com.quickblox.core.QBSettings;
import com.quickblox.core.result.Result;
import com.quickblox.module.auth.QBAuth;
import com.quickblox.module.chat.QBChatService;

public class SplashActivity extends Activity {

	private ProgressBar progressBar;
	private UserManager userManager;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_splash);

		progressBar = (ProgressBar) findViewById(R.id.progressBar);
		userManager = UserManager.createInstance(getApplicationContext());

		QBSettings.getInstance().fastConfigInit(App.APP_ID, App.AUTH_KEY, App.AUTH_SECRET);

		if (!userManager.hasUser()) {
			createSessionForNewUser();
			return;
		}
		
		User currUsre = null;
		try {
			currUser = userManager.getCurrentUser();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (JSONException e) {
			e.printStackTrace();
		}
		createSessionForExistingUser(currUser);
	}

	/*
	 * After LoginActivity or RegisterActivity finishes   
	 */
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == RESULT_OK) {
			QBChatService.getInstance().addConnectionListener(new ConnectionListener() {

				@Override
				public void reconnectionSuccessful() {
					showToast("connectionClosed");
				}

				@Override
				public void reconnectionFailed(Exception e) {
					showToast("reconnectionFailed " + e.getLocalizedMessage());
				}

				@Override
				public void reconnectingIn(int arg0) {
					// TODO Auto-generated method stub
				}

				@Override
				public void connectionClosedOnError(Exception e) {
					showToast("connectionClosed on error " + e.getLocalizedMessage());
				}

				@Override
				public void connectionClosed() {
					showToast("connectionClosed");
				}
			});
			joinRoom();
			finish();
		}
	}

	private void showAuthenticateDialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("Authorize first");
		builder.setItems(new String[] { "Login", "Register" }, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case 0:
					Intent intent = new Intent(SplashActivity.this, LoginActivity.class);
					startActivityForResult(intent, App.AUTHENTICATION_REQUEST);
					break;
				case 1:
					intent = new Intent(SplashActivity.this, RegistrationActivity.class);
					startActivityForResult(intent, App.AUTHENTICATION_REQUEST);
					break;
				}
			}
		});
		builder.show();
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

	private void createSessionForNewUser() {
		QBAuth.createSession(new QBCallback() {
			@Override
			public void onComplete(Result result) {
				progressBar.setVisibility(View.GONE);
				if (result.isSuccess()) {
					Log.d(App.LOG_TAG, "Login new user");
					showAuthenticateDialog();
				} else {
					showErrorDialog(result.getErrors().toString());
				}
			}

			@Override
			public void onComplete(Result result, Object context) {
			}
		});
	}

	private void createSessionForExistingUser(User user) {
		QBAuth.createSession(user.getName(), user.getPassword(), new QBCallback() {
			@Override
			public void onComplete(Result result) {
				progressBar.setVisibility(View.GONE);
				if (result.isSuccess()) {
					Log.d(App.LOG_TAG, "Login existing user");
					joinRoom();
					finish();
				} else {
					showErrorDialog(result.getErrors().toString());
				}
			}

			@Override
			public void onComplete(Result result, Object context) {
			}
		});
	}

	private void joinRoom() {
		Intent intent = new Intent(this, ChatActivity.class);
		Bundle bundle = createChatBundle(getRoomName(), false);
		intent.putExtras(bundle);
		startActivity(intent);
		// ((App)getApplication()).setCurrentRoom();
	}

	private String getRoomName() {
		// return "FB";
		return "DemoRoom";
	}

	private void showErrorDialog(String err_msg) {
		AlertDialog.Builder dialog = new AlertDialog.Builder(getBaseContext());
		dialog.setMessage("Error: " + err_msg).create().show();
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