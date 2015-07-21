package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

import src.ConnectToSQLAzure;

public class LocationDao {
	private Location _location;
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

	public LocationDao(Location _l) {
		this._location = _l;
	}


	public Location getLocation()
	{
		return _location;
	}

	public void createLocation()
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "INSERT INTO tblLocation "
					+ "VALUES ("+ _location.getLocId() + ", "
					+ _location.getLocDesc() + ", " 
					+ _location.getOrgId() + ", "
					+ _location.getUnitSuite() + ", "
					+ _location.getStreet() + ", "
					+ _location.getCity() + ", "
					+ _location.getState() + ", "
					+ _location.getCountry() + ", "
					+ _location.getPostalCode() + ", "
					+ _location.getLatitude() + ", "
					+ _location.getLongitude() + ", "
					+ _location.getLocType() + ", "
					+ _location.getLocSubType() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();

		}
		catch (Exception e)
		{

		}
	}
	
	public static ArrayList<Location> selectLocations()
	{
		ArrayList<Location> locations = new ArrayList<Location>();
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(iOpsConString);

			sqlString = "SELECT * FROM tblLocation";

			if(stmt.execute(sqlString))
			{
				ResultSet result = stmt.getResultSet();
				while(result != null)
				{
					int locId = result.getInt(0);
					String locDesc = result.getString(1);
					int orgId = result.getInt(2);
					String unitSuite = result.getString(3);
					String street = result.getString(4);
					String city = result.getString(5);
					String state = result.getString(6);
					String country = result.getString(7);
					String postalCode = result.getString(8);
					String latitude = result.getString(9);
					String longitude = result.getString(10);
					String locType = result.getString(11);
					String locSubType = result.getString(12);
					
					Location selected = new Location(locId, locDesc, orgId, unitSuite, street, city, state, country, postalCode, latitude, longitude, locType, locSubType);
					locations.add(selected);

					result.next();
				}
				conn.close();

			}
		}
		catch (Exception e)
		{

		}
		return locations;
	}
}