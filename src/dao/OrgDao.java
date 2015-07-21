package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

import src.ConnectToSQLAzure;

public class OrgDao {
	private static String iOpsConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ ConnectToSQLAzure.interceptorOpsDB +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";
	private static String dwConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ ConnectToSQLAzure.dataWarehouseDB +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";

	private static Connection conn = null;
	private static Statement stmt = null;  
	private static String sqlString;

	public static void createOrg(Organization _org)
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "INSERT INTO tblOrganization "
					+ "VALUES ("+ _org.getOrgId() + ", "
								+ _org.getOrgName() + ", " 
								+ _org.getOwnerId() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();

			conn = DriverManager.getConnection(dwConString);

			sqlString = "INSERT INTO DW_Organization_Dim "
					+ "VALUES ("+ _org.getOrgId() + ", "
								+ _org.getOrgName() + ", " 
								+ _org.getOwnerId() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();
			
		}
		catch (Exception e)
		{

		}
	}
	
	public static ArrayList<Organization> selectOrgs()
	{
		ArrayList<Organization> orgs = new ArrayList<Organization>();
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "SELECT * FROM tblOrganization ";
			
			if(stmt.execute(sqlString))
			{
				ResultSet result = stmt.getResultSet();
				while(result != null)
				{
					int orgId = result.getInt(0);
					String orgName = result.getString(1);
					int owner = result.getInt(2);
					
					Organization selected = new Organization(orgId,orgName,owner);
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
