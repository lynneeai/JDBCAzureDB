package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import src.ConnectToSQLAzure;

public class UserDao
{
	private User _user;
	private String dbName = ConnectToSQLAzure.getActiveDB();
	private String connString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ dbName +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";
	
	public Connection conn = null;
	public Statement stmt = null;  
	public String sqlString;
	public User getUser()
	{
		
		
		
		
		return _user;
	}
	
	public void createUser()
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(connString);
			
			sqlString = "INSERT INTO tblUser "
				+ "VALUES (userid, orgid, password, firstname, lastname, regdate, accesslevel)";
			
			stmt.executeUpdate(sqlString);
			
			conn.close();
			
		}
		catch (Exception e)
		{
			
		}
	}
	
	public void createAdminUser()
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(connString);
			
			sqlString = "INSERT INTO tblUser "
				+ "VALUES (userid, orgid, password, firstname, lastname, regdate, accesslevel)";
			
			stmt.executeUpdate(sqlString);
			
			conn.close();
			
		}
		catch (Exception e)
		{
			
		}	
	}
	
}
