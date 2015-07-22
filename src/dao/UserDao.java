package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

import src.ConnectToSQLAzure;

public class UserDao
{
	private static String iOpsConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ ConnectToSQLAzure.interceptorOpsDB +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";

	private static Connection conn = null;
	private static Statement stmt = null; 
	private static PreparedStatement preStmt = null;  
	private static String sqlString;

	public static void createUser(User _user)
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "INSERT INTO tblUser "
					+ "(UserId, OrgId, Password, FirstName, LastName, RegDate, AccessLevel, Credential) "
					+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"; 
			
			preStmt = conn.prepareStatement(sqlString);
			preStmt.setString(1, _user.getUserId());
			preStmt.setInt(2, _user.getOrgId());
			preStmt.setString(3, _user.getPassword());
			preStmt.setString(4, _user.getFirstName());
			preStmt.setString(5, _user.getLastName());
			preStmt.setString(6, _user.getRegDate());
			preStmt.setInt(7, _user.getAccessLevel());
			preStmt.setString(8,  _user.getCredential());
			
			preStmt.executeUpdate();
			
			preStmt.close();

			conn.close();
			
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
	}
	
	public static String selectSingleUser(String userId)
	{
		String lastName = "";
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "SELECT LastName FROM tblUser WHERE " + "UserId='" + userId + "';";
			
			System.out.println(sqlString);
			
			
			stmt = conn.createStatement();
			ResultSet result = stmt.executeQuery(sqlString);
		
			if (result.next())
			{
				lastName = result.getString("LastName");
			}
			System.out.println("Last Name Is: " + lastName);
			
			stmt.close();
			
			conn.close();
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
		return lastName;
		
	}

	public static ArrayList<User> selectUsers()
	{
		ArrayList<User> users = new ArrayList<User>();
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "SELECT * FROM tblUser";
			
			stmt = conn.createStatement();

			if(stmt.execute(sqlString))
			{
				ResultSet result = stmt.getResultSet();
				while(result.next())
				{
					String userId = result.getString(1);
					int orgId = result.getInt(2);
					String password = result.getString(3);
					String firstName = result.getString(4);
					String lastName = result.getString(5);
					String regDate = result.getString(6);
					int accessLevel = result.getInt(7);
					String credential = result.getString(8);
					
					System.out.println("User Info: " + userId + " " + orgId + " " + password + " " + firstName + " " + lastName + " " + regDate + " " + accessLevel + " " + credential);

					User selected = new User(userId, orgId, password, firstName, lastName, regDate, accessLevel, credential);
					users.add(selected);
				}
			}

			stmt.close();
			conn.close();

		}
		catch (Exception e)
		{

		}
		return users;
	}
}
