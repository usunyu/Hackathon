package com.latham.group.utils;

import java.io.IOException;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import com.latham.group.App;
import com.quickblox.module.users.model.QBUser;

/*
 * Manage the session, profile and subscription of current user
 */
public final class UserManager {
	private FileManager fileManager;
	private static UserManager sRef;

	private UserManager(Context context) {
		fileManager = FileManager.createInstance(context);
	}

	public static synchronized UserManager createInstance(Context context) {
		if (sRef == null)
			sRef = new UserManager(context);
		return sRef;
	}

	public static synchronized UserManager getInstance() {
		if (sRef == null)
			throw new IllegalStateException("UserManager::createInstance() should"
					+ "be called before UserManager::getInstance()");
		return sRef;
	}

	public boolean hasUser() {
		return fileManager.has(App.USER_PROFILE);
	}

	public QBUser getCurrentUser() throws IOException, JSONException {
		if (!hasUser())
			return null;
		String user_str = fileManager.read(App.USER_PROFILE);
		JSONObject json_user = JSONManager.getJSONFromString(user_str);
		QBUser user = JSONManager.getUserFromJSON(json_user);
		return user;
	}

	public void deleteUser() {
		fileManager.delete(App.USER_PROFILE);
	}

	public void setCurrentUser(QBUser user) throws JSONException, IOException {
		JSONObject json_user = new JSONObject();
		json_user.put("username", user.getLogin());
		json_user.put("password", user.getPassword());
		json_user.put("id", user.getId());
		storeUserProfileToInternalStorage(json_user.toString());
	}

	private void storeUserProfileToInternalStorage(String profile_str) throws IOException {
		fileManager.write(profile_str, App.USER_PROFILE);
	}
}
