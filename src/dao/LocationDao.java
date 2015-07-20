package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import src.ConnectToSQLAzure;

public class LocationDao {
	private Location _location;
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

			conn = DriverManager.getConnection(connString);

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
}