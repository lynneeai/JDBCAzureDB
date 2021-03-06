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
	private static String cmConString = "jdbc:sqlserver://zypnl8g76k.database.windows.net:1433;"
			+ "database="+ ConnectToSQLAzure.campaignManagerDB +";"
			+ "user=CozDev01_DBA!Us3rAcc0unt@zypnl8g76k;"
			+ "password=Ecru9278Fudge;"
			+ "encrypt=true;"
			+ "hostNameInCertificate=*.database.windows.net;"
			+ "loginTimeout=30;";

	private static Connection conn = null;
	private static Statement stmt = null;
	private static PreparedStatement preStmt = null;  
	private static String sqlString;

	public static void createOrgforIOps(Organization _org)
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);
			
			sqlString = "INSERT INTO tblOrganization "
					+ "(OrgName, ApplicationKey, IpAddress, Owner) "
					+ "VALUES (?, ?, ?, ?)";
			
			preStmt = conn.prepareStatement(sqlString);
			preStmt.setString(1, _org.getOrgName());
			preStmt.setString(2, _org.getApplicationKey());
			preStmt.setString(3,  _org.getIpAddress());
			preStmt.setInt(4, _org.getOwnerId());
			
			
			preStmt.executeUpdate();
			
			preStmt.close();

			conn.close();
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
	}
	
	public static void createOrgforDW(Organization _org)
	{
		try
		{
			conn = DriverManager.getConnection(dwConString);

			sqlString = "INSERT INTO DW_Organization_Dim "
					+ "(OrgId, OrgName, ApplicationKey, IpAddress, Owner) "
					+ "VALUES (?, ?, ?, ?, ?)";
			
			preStmt = conn.prepareStatement(sqlString);
			preStmt.setInt(1, _org.getOrgId());
			preStmt.setString(2, _org.getOrgName());
			preStmt.setString(3, _org.getApplicationKey());
			preStmt.setString(4,  _org.getIpAddress());
			preStmt.setInt(5, _org.getOwnerId());
			
			
			preStmt.executeUpdate();
			
			preStmt.close();

			conn.close();
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
	}
	
	public static void createOrgforCM(Organization _org)
	{
		try
		{
			conn = DriverManager.getConnection(cmConString);

			sqlString = "INSERT INTO ORGANIZATION "
					+ "(ID, NAME, TERMS_AND_CONDITIONS, PRIVACY_POLICY, LOGO_URL) "
					+ "VALUES (?, ?, ?, ?, ?)";
			
			preStmt = conn.prepareStatement(sqlString);
			preStmt.setInt(1, _org.getOrgId());
			preStmt.setString(2, _org.getOrgName());
			preStmt.setString(3,  _org.getTermsAndConditions());
			preStmt.setString(4, _org.getPrivacyPolicy());
			preStmt.setString(5,  _org.getLogoUrl());
			
			
			preStmt.executeUpdate();
			
			preStmt.close();

			conn.close();
			
			
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
		}
	}
	
	public static int selectSingleOrg(String orgName)
	{
		int orgId = 0;
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(iOpsConString);
			
			System.out.println(iOpsConString);
			
			sqlString = "SELECT " + "OrgId" + " FROM tblOrganization " + "WHERE OrgName='" + orgName + "';";
			System.out.println(sqlString);
			
			stmt = conn.createStatement();
			ResultSet result = stmt.executeQuery(sqlString);
			
			if (result.next())
			{
				orgId = result.getInt("OrgId");
			}
			System.out.println("orgId is: " + orgId);
			
			stmt.close();
			
			conn.close();
		}
		catch (Exception e) 
		{
			System.out.println(e.toString());
		}
		
		return orgId;
		
	}
	
	public static ArrayList<Organization> selectOrgs()
	{
		ArrayList<Organization> orgs = new ArrayList<Organization>();
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			
			conn = DriverManager.getConnection(iOpsConString);
			
			System.out.println(iOpsConString);
			
			sqlString = "SELECT * FROM tblOrganization ";
			
			stmt = conn.createStatement();
			
			stmt.execute(sqlString);
			ResultSet result = stmt.getResultSet();
			while(result.next())
			{
				int orgId = result.getInt(1);
				String orgName = result.getString(2);
				String applicationKey = result.getString(3);
				String ipAddress = result.getString(4);
				int owner = result.getInt(5);
				
				System.out.println("Org Info: " + orgId + " " + orgName + " " + applicationKey + " " + ipAddress + " " + owner);
				
				Organization selected = new Organization(orgId, orgName, applicationKey, ipAddress, owner);
				orgs.add(selected);
				
			}
			
			stmt.close();
			
			conn.close();
			
			conn = DriverManager.getConnection(dwConString);
			
			System.out.println(dwConString);
			
			sqlString = "SELECT * FROM DW_Organization_Dim ";
			
			stmt = conn.createStatement();
			
			stmt.execute(sqlString);
			result = stmt.getResultSet();
			while(result.next())
			{
				int orgId = result.getInt(1);
				String orgName = result.getString(2);
				String applicationKey = result.getString(3);
				String ipAddress = result.getString(4);
				int owner = result.getInt(5);
				
				System.out.println("Org Info: " + orgId + " " + orgName + " " + applicationKey + " " + ipAddress + " " + owner);
				
				Organization selected = new Organization(orgId, orgName, applicationKey, ipAddress, owner);
				orgs.add(selected);
				
			}
			
			stmt.close();
			
			conn.close();
			
			conn = DriverManager.getConnection(cmConString);
			
			System.out.println(cmConString);
			
			sqlString = "SELECT * FROM ORGANIZATION ";
			
			stmt = conn.createStatement();
			
			stmt.execute(sqlString);
			result = stmt.getResultSet();
			while(result.next())
			{
				int orgId = result.getInt(1);
				String orgName = result.getString(2);
				String termsAndConditions = result.getString(3);
				String privacyPolicy = result.getString(4);
				String logoUrl = result.getString(5);
				
				System.out.println("Org Info: " + orgId + " " + orgName + " " + termsAndConditions + " " + privacyPolicy + " " + logoUrl);
				
				Organization selected = new Organization(orgId, orgName, termsAndConditions, privacyPolicy, logoUrl);
				orgs.add(selected);
				
			}
			
			stmt.close();
			
			conn.close();
			
		}
		catch (Exception e)
		{
			System.out.println(e.toString());
			
		}
		return orgs;
	}
}
