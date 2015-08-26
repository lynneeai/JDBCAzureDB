package src.dao;

import src.PasswordCredential;

public class User 
{
	private static String userId;
	private static int orgId;
	private static String firstName;
	private static String lastName;
	private static String regDate;
	private static int accessLevel;
	private static PasswordCredential credential;
	
	public User() {}
	
	public User(String userid, int orgid, PasswordCredential pwd, String fname, String lname, String regdate, int accesslevel)
	{
		userId = userid;
		orgId = orgid;
		firstName = fname;
		lastName = lname;
		regDate = regdate;
		accessLevel = accesslevel;
	}
	
	public String getUserId()
	{
		return userId;
	}
	
	public int getOrgId()
	{
		return orgId;
	}
	
	public String getFirstName()
	{
		return firstName;
	}
	
	public String getLastName()
	{
		return lastName;
	}
	
	public String getRegDate()
	{
		return regDate;
	}
	
	public int getAccessLevel()
	{
		return accessLevel;
	}
	
	public PasswordCredential getCredential()
	{
		return credential;
	}
}