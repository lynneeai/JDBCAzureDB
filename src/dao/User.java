package src.dao;

public class User 
{
	private static String userId;
	private static int orgId;
	private static String password;
	private static String firstName;
	private static String lastName;
	private static String regDate;
	private static int accessLevel;
	private static String credential;
	
	public User() {}
	
	public User(String userid, int orgid, String pwd, String fname, String lname, String regdate, int accesslevel, String Credential)
	{
		userId = userid;
		orgId = orgid;
		password = pwd;
		firstName = fname;
		lastName = lname;
		regDate = regdate;
		accessLevel = accesslevel;
		credential = Credential;
	}
	
	public String getUserId()
	{
		return userId;
	}
	
	public int getOrgId()
	{
		return orgId;
	}
	
	public String getPassword()
	{
		return password;
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
	
	public String getCredential()
	{
		return credential;
	}
}