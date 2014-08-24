package com.latham.group.utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.quickblox.module.users.model.QBUser;


/*
 * Manage the conversion between JSON and other data structure 
 */
public class JSONManager {

	/**
	 * The string may be a JSONObject or JSONArray, so we should use this method
	 * instead of getting the JSONObject by constructor
	 */
	public static JSONObject getJSONFromString(String str) throws JSONException {
		JSONObject json = null;
		if (str != "") {
			if (str.charAt(0) == '{')
				json = new JSONObject(str);
			else {
				json = new JSONObject();
				json.put("array", new JSONArray(str));
			}
		}
		return json;
	}

	public static QBUser getUserFromJSON(JSONObject json_user) throws JSONException {
		// Log.d("JSON", "user: " + json_user.toString());
		QBUser user = new QBUser();
		user.setLogin(json_user.getString("username"));
		user.setPassword(json_user.getString("password"));
		user.setId(json_user.getInt("id"));
		return user;
	}
}
