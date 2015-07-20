package src.dao;

public class Interceptor {
	
	private int intId;
	private String intSerial;
	private int orgId;
	private int locId;
	private String intLocDesc;
	private String forwardURL;
	private String forwardType;
	private String maxBatchWaitTime;
	private String deviceStatus;
	private String startURL;
	private String reportURL;
	private String scanURL;
	private String bkupURL;
	private String capture;
	private String captureMode;
	private String requestTimeoutValue;
	private String callHomeTimeoutMode;
	private String callHomeTimeoutData;
	private String dynCodeFormat;
	private String security;
	private String errorLog;
	private String wpaPSK;
	private String ssid;
	private String cmdURL;
	private String cmdChkInt;
	private String interceptorType;

	public Interceptor() {}
	
	public Interceptor(int intid, String s, int orgid, int locid, String intlocdesc, 
					String furl, String ftype, String mbwt, String status, String starturl, String reporturl, String scanurl, String bkupurl, 
					String Capture, String capturemode, String rtov, String chtom, String chtod, String dyncf, String Security, String errlog,
					String wpapsk, String SSID, String cmdurl, String cmdchkint, String inttype)
	{
		intId = intid;
		intSerial = s;
		orgId = orgid;
		locId = locid;
		intLocDesc = intlocdesc;
		forwardURL = furl;
		forwardType = ftype;
		maxBatchWaitTime = mbwt;
		deviceStatus = status;
		startURL = starturl;
		reportURL = reporturl;
		scanURL = scanurl;
		bkupURL = bkupurl;
		capture = Capture;
		captureMode = capturemode;
		requestTimeoutValue = rtov;
		callHomeTimeoutMode = chtom;
		callHomeTimeoutData = chtod;
		dynCodeFormat = dyncf;
		security = Security;
		errorLog = errlog;
		wpaPSK = wpapsk;
		ssid = SSID;
		cmdURL = cmdurl;
		cmdChkInt = cmdchkint;
		interceptorType = inttype;
	}

	public int getIntId()
	{
		return intId;
	}
	
	public String getIntSerial()

	{
		return intSerial;
	}

	public int getOrgId()
	{
		return orgId;
	}
	
	public int getLocId()
	{
		return locId;
	}
	
	public String getIntLocDesc()
	{
		return intLocDesc;
	}
	
	public String getForwardURL()
	{
		return forwardURL;
	}
	
	public String getForwardType()
	{
		return forwardType;
	}
	
	public String getMaxBatchWaitTime()
	{
		return maxBatchWaitTime;
	}
	
	public String getDeviceStatus()
	{
		return deviceStatus;
	}
	
	public String getStartURL()
	{
		return startURL;
	}
	
	public String getReportURL()
	{
		return reportURL;
	}
	
	public String getScanURL()
	{
		return scanURL;
	}
	
	public String getBkupURL()
	{
		return bkupURL;
	}
	
	public String getCapture()
	{
		return capture;
	}
	
	public String getCaptureMode()
	{
		return captureMode;
	}
	
	public String getRequestTimeoutValue()
	{
		return requestTimeoutValue;
	}
	
	public String getCallHomeTimeoutMode()
	{
		return callHomeTimeoutMode;
	}

	public String getCallHomeTimeoutData()
	{
		return callHomeTimeoutData;
	}
	
	public String getDynCodeFormat()
	{
		return dynCodeFormat;
	}
	
	public String getSecurity()
	{
		return security;
	}
	
	public String getErrorLog()
	{
		return errorLog;
	}
	
	public String getWpaPSK()
	{
		return wpaPSK;
	}
	
	public String getSsid()
	{
		return ssid;
	}
	
	public String getCmdURL()
	{
		return cmdURL;
	}
	
	public String getCmdChkInt()
	{
		return cmdChkInt;
	}
	
	public String getInterceptorType()
	{
		return interceptorType;
	}
}
