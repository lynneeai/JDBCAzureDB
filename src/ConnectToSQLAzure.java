package src;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.io.Writer;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;

import src.dao.OrgDao;
import src.dao.Organization;
import src.dao.User;
import src.dao.UserDao;

public class ConnectToSQLAzure 
{
	private static final String timestamp = String.valueOf(Calendar.getInstance().getTimeInMillis());
	
	private static final String dateTime = "2013-09-04T14:09:51.7303861+00:00";
	
	public static final String campaignManagerScript = "CampaignManager";
	public static final String couponManagerScript = "CouponManager";
	public static final String dataWarehouseScript = "DataWarehouse";
	public static final String interceptorOpsScript = "interceptoropsandadmintables";
	public static final String subscriptionManagerScript = "SubscriptionManager";
	public static String campaignManagerDB = campaignManagerScript+timestamp;
	public static String couponManagerDB = couponManagerScript+timestamp;
	public static String dataWarehouseDB = dataWarehouseScript+timestamp;
	public static String interceptorOpsDB = interceptorOpsScript+timestamp;
	public static String subscriptionManagerDB = subscriptionManagerScript+timestamp;

	private static String[] scripts = {campaignManagerScript, couponManagerScript, dataWarehouseScript, interceptorOpsScript, subscriptionManagerScript};
	private static ArrayList<String> dbNames = new ArrayList<String>();
	public static Writer output;

	private static String activeDB;
	
	public static void main(String[] args)
	{
		PasswordCredential pw = null;
		BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));
		
		try
		{
			File outputFile = new File("out.txt");
			if (!outputFile.exists())
			{
				outputFile.createNewFile();
			}
			FileOutputStream os = new FileOutputStream(outputFile);
			OutputStreamWriter osw = new OutputStreamWriter(os, "UTF-8");
			output = new BufferedWriter(osw);
		}
		catch (Exception e)
		{
		}
		
		try
		{
			System.out.println("Enter password: ");
			String s = bufferedReader.readLine();
			pw = PasswordBuilder.buildCredential(s);
		}
		catch (NoSuchAlgorithmException e1)
		{
			e1.printStackTrace();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		//PasswordCredential pwConf;
		try
		{
			System.out.println("Enter password: ");
			String s = bufferedReader.readLine();
			System.out.println(PasswordHash.validatePassword(s, pw.getPassword().toString()));
		}
		catch (NoSuchAlgorithmException e1)
		{
			e1.printStackTrace();
		}
		catch (InvalidKeySpecException e2)
		{
			e2.printStackTrace();
		}
		catch (IOException e3)
		{
			e3.printStackTrace();
		}

		for (String nextScript : scripts)
		{
			dbNames.add(initScript(nextScript));
		}

		populateDatabases();
		
		
		try
		{
			System.out.println("Scripts run. Hit 'Enter' to drop created databases...");
			bufferedReader.readLine();
		}
		catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		for (String nextDB : dbNames)
		{
			System.out.println("Attempting to drop database: " + nextDB);
			dropDb(nextDB);
		}
	}
	

	private static void populateDatabases()
	{
		Organization rootOrg = new Organization("root", "applicationkey", "ipaddress", 1);
		OrgDao.createOrg(rootOrg);
		
		Organization varOrg = new Organization("var", "applicationkey", "ipaddress", 1);
		OrgDao.createOrg(varOrg);
		
		Organization retailOrg = new Organization("retailer", "applicationkey", "ipaddress", 1);
		OrgDao.createOrg(retailOrg);
		OrgDao.selectOrgs();

		User rootUser = new User("User1", 1, "password1", "Firstname", "McLastName", dateTime, 1, null);
		UserDao.createUser(rootUser);
		
		User varUser = new User("User2", 2, "password2", "A.", "Elum-Eho", dateTime, 3, null);
		UserDao.createUser(varUser);
		
		User retailUser = new User("User3", 3, "password3", "First", "LastName", dateTime, 5, null);
		UserDao.createUser(retailUser);
		UserDao.selectUsers();
	}
	
	private static String initScript (String script)
	{
		String dbName = script + timestamp;
		setActiveDB(dbName);
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

			// Create new database
			System.out.println("Server connecting to master...");
			output.write("Server connection to master...\n");
			connection = DriverManager.getConnection(masterConnectionString);
			System.out.println("Server connected.");
			output.write("Server connected.\n");

			sqlString = "CREATE DATABASE " + dbName;


			statement = connection.createStatement();
			statement.executeUpdate(sqlString);

			System.out.println("New database created.");
			output.write("New database " + dbName + " created.\n");
			statement.close();
			connection.close();
			
			/*
			// populate organization table
			System.out.println("Server connecting to " + dbName + "...");
			output.write("Server connecting to " + dbName + "...\n");
			connection = DriverManager.getConnection(dbConnectionString);
			System.out.println("Server connected.");
			output.write("Server connected.\n");
			
			
			sqlString = "CREATE TABLE tblOrganization (" 
						+ "orgId INTEGER, "
						+ "orgName VARCHAR(30), "
						+ "ownerId INTEGER, "
						+ "PRIMARY KEY (orgName) )";
			
			statement = connection.createStatement();
			statement.executeUpdate(sqlString);
			
			System.out.println("Table tblOrganization created.");
			output.write("Table tblOrganization created.\n");
			statement.close();
			connection.close();
			
			
			// populate user table
			System.out.println("Server connecting to " + dbName + "...");
			output.write("Server connecting to " + dbName + "...\n");
			connection = DriverManager.getConnection(dbConnectionString);
			System.out.println("Server connected.");
			output.write("Server connected.\n");
			
			sqlString = "CREATE TABLE tblUser (" 
						+ "userId INTEGER, "
						+ "orgId INTEGER, "
						+ "password VARCHAR(30), "
						+ "firstName VARCHAR(30), "
						+ "lastName VARCHAR(30), "
						+ "regDate VARCHAR(30), "
						+ "accessLevel INTEGER, "
						+ "PRIMARY KEY (userId) )";
			
			statement = connection.createStatement();
			statement.executeUpdate(sqlString);
			
			System.out.println("Table tblUser created.");
			output.write("Table tblUser created.\n");
			statement.close();
			connection.close();
			*/

			System.out.println("Server connecting to " + dbName + "...");
			output.write("Server connecting to " + dbName + "...\n");
			connection = DriverManager.getConnection(dbConnectionString);
			statement = connection.createStatement();
			System.out.println("Server connected.");
			output.write("Server connected.\n");

			ScriptExecutor.executeScript(statement, script);
			connection.close();

			System.out.println("Processing complete.");
			output.write("Processing complete.\n");
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
		return dbName;
	}

	private static void dropDb (String dbName)
	{
		// Create a variable for the connection string.
		String masterConnectionString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
				+ "database=master;"
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

			System.out.println("Server connecting to master...");
			output.write("Server connecting to master...\n");

			connection = DriverManager.getConnection(masterConnectionString);
			statement = connection.createStatement();

			System.out.println("Server connected.");
			output.write("Server connected.\n");
			String sqlDropString = "DROP DATABASE " + dbName;
			statement.executeUpdate(sqlDropString);
			statement.close();
			connection.close();
			System.out.println("DB dropped.");
			output.write("Database " + dbName + " dropped.\n");
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
	
	public static String getActiveDB()
	{
		return activeDB;
	}
	
	public static void setActiveDB(String newDB)
	{
		activeDB = newDB;
	}
}