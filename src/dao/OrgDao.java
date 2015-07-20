package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import src.ConnectToSQLAzure;

public class OrgDao {
	private Organization _org;
	private String dbName = ConnectToSQLAzure.getActiveDB();
	private String connString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ dbName +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";

	private Connection conn = null;
	private Statement stmt = null;  
	private String sqlString;
	
	public OrgDao() {
		// TODO Auto-generated constructor stub
	}


	public Organization getOrg()
	{
		return _org;
	}

	public void createOrg(int orgId, String orgName, String applicationKey, String ipAddress, int owner)
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(connString);

			sqlString = "INSERT INTO tblOrganization "
					+ "VALUES ("+orgId+", "+orgName+", "+applicationKey+", "+ipAddress+", "+owner+")";

			stmt.executeUpdate(sqlString);

			conn.close();

		}
		catch (Exception e)
		{

		}
	}

}
