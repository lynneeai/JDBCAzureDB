package src.dao;

public class Interceptor {
	String intId;
	String intSerial;
	String orgId;
	String locId;
	String intLocDesc;
	String forwardURL;
	String forwardType;
	String maxBatchWaitTime;
	String deviceStatus;
	String startURL;
	String reportURL;
	String scanURL;
	String bkupURL;
	String capture;
	String captureMode;
	String requestTimeoutValue;
	String callHomeTimeoutMode;
	String callHomeTimeoutData;
	String dynCodeFormat;
	String security;
	String errorLog;
	String wpaPSK;
	String ssid;
	String cmdURL;
	String cmdChkInt;
	String interceptorType;
	
	public Interceptor(String intId, String intSerial, String orgId, String locId, String intLocDesc, String forwardURL, String forwardType, String maxBatchWaitTime, String deviceStatus, String reportURL,
			String startURL, String scanURL, String bkupURL, String capture, String captureMode, String requestTimeoutValue, String callHomeTimeoutMode, String callHomeTimeoutData, String dynCodeFormat,
			String security, String errorLog, String wpaPSK, String ssid, String cmdURL, String cmdChkInt, String interceptorType)
	{
		this.intId = intId;
		this.intSerial = intSerial;
		this.orgId = orgId;
		this.locId = locId;
		this.intLocDesc = intLocDesc;
		this.forwardURL = forwardURL;
		this.forwardType = forwardType;
		this.maxBatchWaitTime = maxBatchWaitTime;
		this.deviceStatus = deviceStatus;
		this.startURL = startURL;
		this.reportURL = reportURL;
		this.scanURL = scanURL;
		this.bkupURL = bkupURL;
		this.capture = capture;
		this.captureMode = captureMode;
		this.requestTimeoutValue = requestTimeoutValue;
		this.callHomeTimeoutMode = callHomeTimeoutMode;
		this.callHomeTimeoutData = callHomeTimeoutData;
		this.dynCodeFormat = dynCodeFormat;
		this.security = security;
		this.errorLog = errorLog;
		this.wpaPSK = wpaPSK;
		this.ssid = ssid;
		this.cmdURL = cmdURL;
		this.cmdChkInt = cmdChkInt;
		this.interceptorType = interceptorType;
	}

	public String getIntId() {return this.intId;}
	public String getIntSerial() {return this.intSerial;}
	public String getOrgId() {return this.orgId;}
	public String getLocId() {return this.locId;}
	public String getIntLocDesc() {return this.intLocDesc;}
	public String getForwardURL() {return this.forwardURL;}
	public String getForwardType() {return this.forwardType;}
	public String getMaxBatchWaitTime() {return this.maxBatchWaitTime;}
	public String getDeviceStatus() {return this.deviceStatus;}
	public String getStartURL() {return this.startURL;}
	public String getReportURL() {return this.reportURL;}
	public String getScanURL() {return this.scanURL;}
	public String getBkupURL() {return this.bkupURL;}
	public String getCapture() {return this.capture;}
	public String getCaptureMode() {return this.captureMode;}
	public String getRequestTimeoutValue() {return this.requestTimeoutValue;}
	public String getCallHomeTimeoutMode() {return this.callHomeTimeoutMode;}
	public String getCallHomeTimeoutData() {return this.callHomeTimeoutData;}
	public String getDynCodeFormat() {return this.dynCodeFormat;}
	public String getSecurity() {return this.security;}
	public String getErrorLog() {return this.errorLog;}
	public String getWpaPSK() {return this.wpaPSK;}
	public String getSsid() {return this.ssid;}
	public String getCmdURL() {return this.cmdURL;}
	public String getCmdChkInt() {return this.cmdChkInt;}
	public String getInterceptorType() {return this.interceptorType;}
 
}
