package src.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import src.ConnectToSQLAzure;

public class InterceptorDao {
	private Interceptor _i;
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
	public InterceptorDao(Interceptor i) {
		this._i = i;
	}
	public Interceptor getInterceptor()
	{
		return _i;
	}

	public void createInterceptor()
	{
		try
		{
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

			conn = DriverManager.getConnection(connString);

			sqlString = "INSERT INTO tblInterceptor "
					+ "VALUES ("+ _i.getIntId() + ", "
					+ _i.getIntSerial() + ", " 
					+ _i.getOrgId() + ", " 
					+ _i.getLocId() + ", " 
					+ _i.getIntLocDesc() + ", " 
					+ _i.getForwardURL() + ", " 
					+ _i.getForwardType() + ", " 
					+ _i.getMaxBatchWaitTime() + ", " 
					+ _i.getDeviceStatus() + ", " 
					+ _i.getStartURL() + ", " 
					+ _i.getReportURL() + ", " 
					+ _i.getScanURL() + ", " 
					+ _i.getBkupURL() + ", " 
					+ _i.getCapture() + ", " 
					+ _i.getCaptureMode() + ", " 
					+ _i.getRequestTimeoutValue() + ", " 
					+ _i.getCallHomeTimeoutMode() + ", " 
					+ _i.getCallHomeTimeoutData() + ", " 
					+ _i.getDynCodeFormat() + ", " 
					+ _i.getSecurity() + ", " 
					+ _i.getErrorLog() + ", " 
					+ _i.getWpaPSK() + ", " 
					+ _i.getSsid() + ", " 
					+ _i.getCmdURL() + ", " 
					+ _i.getCmdChkInt() + ", " 
					+ _i.getInterceptorType() + ")";

			stmt.executeUpdate(sqlString);

			conn.close();

		}
		catch (Exception e)
		{

		}
	}
}
