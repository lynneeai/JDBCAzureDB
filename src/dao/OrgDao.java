package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.sql.*;

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
	private static PreparedStatement preStmt = null;  
	private static String sqlString;

	public static void createOrg(Organization _org)
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "INSERT INTO tblOrganization "
					+ "(orgId, orgName, ownerId) "
					+ "VALUES (?, ?, ?)";
			
			preStmt = conn.prepareStatement(sqlString);
			preStmt.setInt(1, _org.getOrgId());
			preStmt.setString(2, _org.getOrgName());
			preStmt.setInt(3, _org.getOwnerId());
			
			
			preStmt.executeUpdate();
			
			preStmt.close();

			conn.close();

			conn = DriverManager.getConnection(dwConString);

			sqlString = "INSERT INTO tblOrganization "
					+ "(orgId, orgName, ownerId) "
					+ "VALUES (?, ?, ?)";
			
			preStmt = conn.prepareStatement(sqlString);
			preStmt.setInt(1, _org.getOrgId());
			preStmt.setString(2, _org.getOrgName());
			preStmt.setInt(3, _org.getOwnerId());
			
			
			preStmt.executeUpdate();
			
			preStmt.close();

			conn.close();
			
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
	}
	
	public static String selectSingleOrg(int orgId)
	{
		String orgName = "";
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "SELECT " + "orgName" + " FROM tblOrganization " + "WHERE orgId=" + orgId;
			System.out.println(sqlString);
			
			stmt = conn.createStatement();
			ResultSet result = stmt.executeQuery(sqlString);
			
			orgName = result.getString("orgName");
			System.out.println("orgName is: " + orgName);
			
			conn.close();
		}
		catch (Exception e) 
		{
			System.out.println(e.toString());
		}
		
		return orgName;
		
	}
	
	public static ArrayList<Organization> selectOrgs()
	{
		ArrayList<Organization> orgs = new ArrayList<Organization>();
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "SELECT * FROM tblOrganization ";
			
			stmt = conn.createStatement();
			
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
