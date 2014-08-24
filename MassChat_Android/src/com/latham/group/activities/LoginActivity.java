package com.latham.group.activities;

import java.io.IOException;

import org.json.JSONException;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

import com.latham.group.App;
import com.latham.group.R;
import com.latham.group.utils.UserManager;
import com.quickblox.core.QBCallback;
import com.quickblox.core.result.Result;
import com.quickblox.module.chat.QBChatService;
import com.quickblox.module.chat.listeners.SessionCallback;
import com.quickblox.module.chat.smack.SmackAndroid;
import com.quickblox.module.users.QBUsers;
import com.quickblox.module.users.model.QBUser;

/*
 * Login the User
 */
public class LoginActivity extends Activity {

	private static final String TAG = LoginActivity.class.getSimpleName();

	private Button loginButton;
	private EditText loginEdit;
	private EditText passwordEdit;
	private ProgressDialog progressDialog;
	private String login;
	private String password;
	private QBUser currUser;
	private SmackAndroid smackAndroid;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login);

		loginEdit = (EditText) findViewById(R.id.loginEdit);
		passwordEdit = (EditText) findViewById(R.id.passwordEdit);
		loginEdit.setText(App.DEFAULT_USER_NAME);
		passwordEdit.setText(App.DEFAULT_USER_PASSWORD);
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage("Loading");
		loginButton = (Button) findViewById(R.id.loginButton);
		loginButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				login = loginEdit.getText().toString();
				password = passwordEdit.getText().toString();
				currUser = new QBUser(login, password);
				progressDialog.show();
				
				QBUsers.signIn(currUser, new QBCallback() {

					@Override
					public void onComplete(Result result) {
						try {
							if (result.isSuccess()) {
								UserManager.getInstance().setCurrentUser(currUser);
								
								if (progressDialog != null) {
									progressDialog.dismiss();
								}
								loginWithUser(currUser);
							} else {
								AlertDialog.Builder dialog = new AlertDialog.Builder(getBaseContext());
								dialog.setMessage("Errors: " + result.getErrors()).create().show();
							}
						} catch (JSONException e) {
							e.printStackTrace();
						} catch (IOException e) {
							e.printStackTrace();
						}
					}

					@Override
					public void onComplete(Result result, Object context) {
					}
				});
			}
		});

		smackAndroid = SmackAndroid.init(this);
	}

	@Override
	protected void onDestroy() {
		smackAndroid.onDestroy();
		super.onDestroy();
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		setResult(RESULT_CANCELED, new Intent());
		finish();
	}
	
	private void loginWithUser(QBUser user){
		QBChatService.getInstance().loginWithUser(user, new SessionCallback() {
			@Override
			public void onLoginSuccess() {
				if (progressDialog != null) {
					progressDialog.dismiss();
				}
				Log.i(TAG, "success when login");

				setResult(RESULT_OK, new Intent());
				finish();
			}

			@Override
			public void onLoginError(String error) {
				Log.i(TAG, "error when login");
			}
		});
	}

}
