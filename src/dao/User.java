package src.dao;

public class User 
{
	private static int userId;
	private static int orgId;
	private static String password;
	private static String firstName;
	private static String lastName;
	private static String regDate;
	
	//1 = root
	private static int accessLevel;
	
	public User() {}
	
	public User(int userid, int orgid, String pwd, String fname, String lname, String regdate, int accesslevel)
	{
		userId = userid;
		orgId = orgid;
		password = pwd;
		firstName = fname;
		lastName = lname;
		regDate = regdate;
		accessLevel = accesslevel;
	}
	
	public int getUserId()
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
}