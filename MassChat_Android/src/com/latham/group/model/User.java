package com.latham.group.model;


/*
 * Each session has one user
 */
public class User {

	private String name;
	private String password;

	public User() {
		name = "";
		password = "";
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setPassword(String password){
		this.password = password;
	}
	
	public String getPassword(){
		return password;
	}
	
	public String toString() {
		return name + " " + password;
	}
}
