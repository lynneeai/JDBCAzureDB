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
	/*
	public static String campaignManagerDB = campaignManagerScript+timestamp;
	public static String couponManagerDB = couponManagerScript+timestamp;
	public static String dataWarehouseDB = dataWarehouseScript+timestamp;
	public static String interceptorOpsDB = interceptorOpsScript+timestamp;
	public static String subscriptionManagerDB = subscriptionManagerScript+timestamp;
	*/
	
	public static String campaignManagerDB = "CampaignManager1438094000625";
	public static String couponManagerDB = "CouponManager1438094000625";
	public static String dataWarehouseDB = "DataWarehouse1438094000625";
	public static String interceptorOpsDB = "interceptoropsandadmintables1438094000625";
	public static String subscriptionManagerDB = "SubscriptionManager1438094000625";
	

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
		/*
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
		 */

		for (String nextScript : scripts)
		{
			dbNames.add(initScript(nextScript));
		}
		htmlInsert();
		populateDatabases();
		
		dropTable();


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
	
	private static void dropTable()
	{
		String cmConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
				+ "database="+ campaignManagerDB +";"
				+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
				+ "password=Ecru9278Fudge;"
				+ "encrypt=true;"
				+ "hostNameInCertificate=*.database.windows.net;"
				+ "loginTimeout=30;";
		
		Connection connection = null;
		Statement statement = null;
		
		String sqlString;
		
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			connection = DriverManager.getConnection(cmConString);
			
			sqlString = "DROP TABLE SEGMENT;";
			statement = connection.createStatement();
			statement.executeUpdate(sqlString);
			
			statement.close();
			connection.close();
			
		}
		catch (Exception e)
		{
			
		}

	}

	private static void htmlInsert()
	{
		String dbConnectionString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
				+ "database="+campaignManagerDB+";"
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
			connection = DriverManager.getConnection(dbConnectionString);
			System.out.println("Server connected.");
			output.write("Server connected.\n");

			System.out.println("Server connecting to " + campaignManagerDB + "...");
			output.write("Server connecting to " + campaignManagerDB + "...\n");
			connection = DriverManager.getConnection(dbConnectionString);
			statement = connection.createStatement();
			System.out.println("Server connected.");
			output.write("Server connected.\n");

			sqlString = "INSERT INTO [dbo].[GENERIC_TEMPLATE]([key],[VALUE])VALUES('MESSAGE_SubscriptionActivated','  <html style=\"margin: 0 auto;\">  <head>    <meta charset=\"utf-8\" />      </head>    <body>  <div class=\"body\" style=\"font-family: Arial, Helvetica, sans-serif; color: rgba(0, 0, 0, 0.6); font-size: 16px; text-align: center; max-width: 640px; margin: 2em auto;\">    <img class=\"logo\" src=\"*|LOGO|*\" alt=\"\" style=\"max-width: 150px; max-height: 150px;\" />    <h1>*|CAMPAIGN_DESC|*</h1>    <h2>*|COUPON_DESC|*</h2>    <div class=\"barcode\" style=\"padding: 2em 0;\">      <img src=\"cid:barcode.png\" alt=\"Digital Coupon\" style=\"max-width: 100px; max-height: 100px;\" />    </div>      <footer style=\"margin-top: 3em;\">      <!-- PRIVACY POLICY -->      <div class=\"terms\" style=\"font-size: 0.6em;\">        *|TANDC|*      </div>      <div class=\"opt-out\" style=\"margin: 2em 0; font-size: 0.7em;\">        If you wish to opt-out of future communications please        <a href=\"http://dev.ourlist.co/*|SLUG|*/unsubscribe/?email=*|EMAIL|*\" style=\"text-decoration: none;\">click here.</a>      </div>    </footer>  </div></body>  </html>');";
			statement.executeUpdate(sqlString);
			sqlString = "INSERT INTO [dbo].[GENERIC_TEMPLATE]([key],[VALUE])VALUES('MESSAGE_SubscriptionCreated','     <html style=\"margin: 0 auto;\">   <head>     <meta charset=\"utf-8\" />        </head>   <body>     <div class=\"body\" style=\"font-family: Arial, Helvetica, sans-serif; color: rgba(0, 0, 0, 0.6); font-size: 16px; text-align: center; max-width: 640px; margin: 2em auto;\">     <img class=\"logo\" src=\"*|LOGO|*\" alt=\"\" style=\"max-width: 150px; max-height: 150px;\" />     <h1>*|CAMPAIGN_NAME|*</h1>     <p>       You recently signed up to receive communication from *|PUBLISHER_NAME|*.       Please click the link below to complete your registration.     </p>     <div class=\"activate button\" style=\"background: rgba(192, 192, 192, 0.3); display: inline-block; margin: 2em 0; padding: 1em; width: 250px; cursor: pointer;\"><a href=\"http://dev.ourlist.co/*|SLUG|*/activate/*|ID|*\" style=\"text-decoration: none; margin: 0 auto; font-size: 1.5em; color: inherit;\">CONFIRM</a></div>     <p>If you did not submit this request, please disregard this message.</p>     </div>  </body></html> ');";
			statement.executeUpdate(sqlString);
			sqlString = "INSERT INTO [dbo].[GENERIC_TEMPLATE]([key],[VALUE])VALUES('SUBJECT_SubscriptionCreated','Confirmation Required');";
			statement.executeUpdate(sqlString);
			sqlString = "INSERT INTO [dbo].[GENERIC_TEMPLATE]([key],[VALUE])VALUES('SUBJECT_SubscriptionActivated','Subscription Confirmed');";
			statement.executeUpdate(sqlString);

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
	}

	private static void populateDatabases()
	{
		Organization rootOrg = new Organization("root", "applicationkey", "ipaddress", 1);
		OrgDao.createOrgforIOps(rootOrg);

		Organization varOrg = new Organization("var", "applicationkey", "ipaddress", 1);
		OrgDao.createOrgforIOps(varOrg);

		Organization retailOrg = new Organization("retailer", "applicationkey", "ipaddress", 1);
		OrgDao.createOrgforIOps(retailOrg);

		Organization rootOrg1 = new Organization(1, "root", "applicationkey", "ipaddress", 1);
		OrgDao.createOrgforDW(rootOrg1);

		Organization varOrg1 = new Organization(2, "var", "applicationkey", "ipaddress", 1);
		OrgDao.createOrgforDW(varOrg1);

		Organization retailOrg1 = new Organization(3, "retailer", "applicationkey", "ipaddress", 1);
		OrgDao.createOrgforDW(retailOrg1);


		Organization rootOrg2 = new Organization(1, "root", "terms and conditions", "privacy policy", "logo url");
		OrgDao.createOrgforCM(rootOrg2);

		Organization varOrg2 = new Organization(2, "var", "terms and conditions", "privacy policy", "logo url");
		OrgDao.createOrgforCM(varOrg2);

		Organization retailOrg2 = new Organization(3, "retail", "terms and conditions", "privacy policy", "logo url");
		OrgDao.createOrgforCM(retailOrg2);

		OrgDao.selectOrgs();

		try {
			PasswordCredential pc1;
			pc1 = PasswordBuilder.buildCredential("password1");
			User rootUser = new User("User1", 1, pc1, "Firstname", "McLastName", dateTime, 1);
			UserDao.createUser(rootUser);

			PasswordCredential pc2 = PasswordBuilder.buildCredential("password2");
			User varUser = new User("User2", 2, pc2, "A.", "Elum-Eho", dateTime, 3);
			UserDao.createUser(varUser);

			PasswordCredential pc3 = PasswordBuilder.buildCredential("password3");
			User retailUser = new User("User3", 3, pc3, "First", "LastName", dateTime, 5);
			UserDao.createUser(retailUser);
		} catch (NoSuchAlgorithmException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvalidKeySpecException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		UserDao.selectUsers();
	}

	private static String initScript (String script)
	{
		String dbName = script + "1438094000625";
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