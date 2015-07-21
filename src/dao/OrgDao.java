package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

import src.ConnectToSQLAzure;

public class OrgDao {
	private Organization _org;
	private String iOpsConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ ConnectToSQLAzure.interceptorOpsDB +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";
	private String dwConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ ConnectToSQLAzure.dataWarehouseDB +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";

	private Connection conn = null;
	private Statement stmt = null;  
	private String sqlString;
	
	public OrgDao(Organization _org)
	{
		this._org = _org;
	}


	public Organization getOrg()
	{
		return _org;
	}

	public void createOrg()
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "INSERT INTO tblOrganization "
					+ "VALUES ("+ _org.getOrgId() + ", "
								+ _org.getOrgName() + ", " 
								+ _org.getApplicationKey() + ", "
								+ _org.getIpAddress() + ", "
								+ _org.getOwner() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();

			conn = DriverManager.getConnection(dwConString);

			sqlString = "INSERT INTO DW_Organization_Dim "
					+ "VALUES ("+ _org.getOrgId() + ", "
								+ _org.getOrgName() + ", " 
								+ _org.getApplicationKey() + ", "
								+ _org.getIpAddress() + ", "
								+ _org.getOwner() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();
			
		}
		catch (Exception e)
		{

		}
	}
	
	public ArrayList<Organization> selectOrgs()
	{
		ArrayList<Organization> orgs = new ArrayList<Organization>();
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "SELECT * FROM tblUser";
			
			if(stmt.execute(sqlString))
			{
				ResultSet result = stmt.getResultSet();
				while(result != null)
				{
					int orgId = result.getInt(0);
					String orgName = result.getString(1);
					String applicationKey = result.getString(2);
					String ipAddress = result.getString(3);
					int owner = result.getInt(4);
					
					Organization selected = new Organization(orgId,orgName,applicationKey,ipAddress,owner);
					orgs.add(selected);
					
					result.next();
				}
			}
			
			conn.close();
			
		}
		catch (Exception e)
		{
			
		}
		return orgs;
	}
}
