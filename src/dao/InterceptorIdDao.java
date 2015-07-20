package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import src.ConnectToSQLAzure;

public class InterceptorIdDao {
	private InterceptorId id;
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
	
	public InterceptorIdDao(InterceptorId id) {
		this.id = id;
	}

	
	public InterceptorId getInterceptorId()
	{
		return id;
	}

	public void createInterceptorId()
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(connString);

			sqlString = "INSERT INTO tblInterceptorId "
					+ "VALUES ("+ id.getIntSerial() + ", "
					+ id.getEmbeddedId() + ", " 
					+ id.getKey() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();

		}
		catch (Exception e)
		{

		}
	}
	
}
