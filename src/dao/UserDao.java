package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
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
	private static String sqlString;

	public static void createUser(User _user)
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "INSERT INTO tblUser "
					+ "VALUES (" + _user.getUserId() + "," 
					+ _user.getOrgId() + "," 
					+ _user.getPassword() + "," 
					+ _user.getFirstName() + "," 
					+ _user.getLastName() + "," 
					+ _user.getRegDate() + "," 
					+ _user.getAccessLevel() + ")";

			stmt = conn.createStatement();
			stmt.executeUpdate(sqlString);

			conn.close();
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
	}
	
	public static String selectSingleUser(String userName)
	{
		String lastName = "";
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "SELECT * FROM tblUser WHERE " + "firstName='" + userName + "'";
			
			System.out.println(sqlString);
			
			
			stmt = conn.createStatement();
			ResultSet result = stmt.executeQuery(sqlString);
			
			lastName = result.getString("lastName");
			System.out.println("Last Name Is: " + lastName);
			
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
				while(result != null)
				{
					int userId = result.getInt(0);
					int orgId = result.getInt(1);
					String password = result.getString(2);
					String firstName = result.getString(3);
					String lastName = result.getString(4);
					String regDate = result.getString(5);
					int accessLevel = result.getInt(6);

					User selected = new User(userId,orgId,password,firstName,lastName,regDate,accessLevel);
					users.add(selected);

					result.next();
				}
			}

			conn.close();

		}
		catch (Exception e)
		{

		}
		return users;
	}
}
