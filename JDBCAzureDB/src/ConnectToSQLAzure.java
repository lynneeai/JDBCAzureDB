package src;

import java.sql.*;
import com.microsoft.sqlserver.jdbc.*;

public class ConnectToSQLAzure 
{

	public static void main(String[] args) 
	{

		// Create a variable for the connection string.
		String connectionString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
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
          
			// Establish the connection.
			connection = DriverManager.getConnection(connectionString);
			System.out.println("Server connected.");

			/*
			// Create new database
			String sqlString = "CREATE DATABASE " + "TestForJDBC";
			
			statement = connection.createStatement();
			statement.executeUpdate(sqlString);
          
			System.out.println("New database created.");
			*/
          
			/*
			// Add table
			sqlString = 
				"CREATE TABLE Person (" + 
				"[PersonID] [int] IDENTITY(1,1) NOT NULL," +
				"[LastName] [nvarchar](50) NOT NULL," + 
				"[FirstName] [nvarchar](50) NOT NULL)";

			statement = connection.createStatement();
			statement.executeUpdate(sqlString);

			System.out.println("Processing complete.");
			*/
          
			/*
			// Create index
			sqlString = 
				"CREATE CLUSTERED INDEX index1 " + "ON Person (PersonID)";

			statement = connection.createStatement();
			statement.executeUpdate(sqlString);

			System.out.println("Processing complete.");
			*/
			
			/*
			// Insert data
			sqlString = 
        	  "SET IDENTITY_INSERT Person ON " + 
        	  "INSERT INTO Person " + 
        	  "(PersonID, LastName, FirstName) " + 
        	  "VALUES(1, 'Abercrombie', 'Kim')," + 
        	  "(2, 'Goeschl', 'Gerhard')," + 
        	  "(3, 'Grachev', 'Nikolay')," + 
        	  "(4, 'Yee', 'Tai')," + 
        	  "(5, 'Wilson', 'Jim')";

          	statement = connection.createStatement();
          	statement.executeUpdate(sqlString);

			System.out.println("Processing complete.");
			*/

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

