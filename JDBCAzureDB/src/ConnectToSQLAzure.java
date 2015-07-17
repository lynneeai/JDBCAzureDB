//package src;

import java.sql.*;
import java.util.Calendar;

public class ConnectToSQLAzure 
{
	public static final String scriptName = "InterceptorOps";
	public static void main(String[] args) 
	{
		String dbName = scriptName + String.valueOf(Calendar.getInstance().getTimeInMillis());

		// Create a variable for the connection string.
		String masterConnectionString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
				+ "database=master;"
				+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
				+ "password=Ecru9278Fudge;"
				+ "encrypt=true;"
				+ "hostNameInCertificate=*.database.windows.net;"
				+ "loginTimeout=30;";

		String dbConnectionString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
				+ "database="+dbName+";"
				+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
				+ "password=Ecru9278Fudge;"
				+ "encrypt=true;"
				+ "hostNameInCertificate=*.database.windows.net;"
				+ "loginTimeout=30;";

		// Declare the JDBC objects.
		Connection connection = null;  // For making the connection
		Statement statement = null;    // For the SQL statement
		ResultSet resultSet = null;    // For the result set, if applicable

		try
		{
			// Ensure the SQL Server driver class is available.
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			String sqlString;
			/*
			// Delete old database
			sqlString = "DROP DATABASE " + dbName;
			
			statement = connection.createStatement();
			statement.executeUpdate(sqlString);
			System.out.println("Old database deleted.");
			statement.close();
			connection.close();
			*/
			
			
			// Create new database
			System.out.println("Server connecting to master...");
			connection = DriverManager.getConnection(masterConnectionString);
			System.out.println("Server connected.");

			sqlString = "CREATE DATABASE " + dbName;


			statement = connection.createStatement();
			statement.executeUpdate(sqlString);

			System.out.println("New database created.");
			statement.close();
			connection.close();
			
			System.out.println("Server connecting to " + dbName + "...");
			connection = DriverManager.getConnection(dbConnectionString);
			statement = connection.createStatement();
			System.out.println("Server connected.");
			
			ScriptExecutor.executeScript(statement, dbName);
			connection.close();
			
			System.out.println("Processing complete.");

			System.out.println("Server connecting to master...");
			
			connection = DriverManager.getConnection(masterConnectionString);
			statement = connection.createStatement();
			
			System.out.println("Server connected.");
			String sqlDropString = "DROP DATABASE " + dbName;
			statement.executeUpdate(sqlDropString);
			statement.close();
			connection.close();
			System.out.println("DB dropped.");
			
			
		}
		// Exception handling
		catch (ClassNotFoundException cnfe)  
		{
			System.out.println("ClassNotFoundException " + cnfe.getMessage());
		}
		catch (Exception e)
		{
			System.out.println("Exception " + e.getMessage());
			e.printStackTrace();
		}
		finally
		{
			try
			{
				// Close resources.
				if (null != connection) connection.close();
				if (null != statement) statement.close();
				if (null != resultSet) resultSet.close();
			}
			catch (SQLException sqlException)
			{
				// No additional action if close() statements fail.
			}
		}
	}
}

