package src.dao;

public class Organization 
{

	private int orgId;
	private String orgName;
	private String applicationKey;
	private String ipAddress;
	private int ownerId;
	
	private String termsAndConditions;
	private String privacyPolicy;
	private String logoUrl;
	
	public Organization() {}
	
	public Organization(int orgid, String orgname, String applicationkey, String ipaddress, int o)
	{
		orgId = orgid;
		orgName = orgname;
		applicationKey = applicationkey;
		ipAddress = ipaddress;
		ownerId = o;
	}
	
	public Organization(String orgname, String applicationkey, String ipaddress, int o)
	{
		orgName = orgname;
		applicationKey = applicationkey;
		ipAddress = ipaddress;
		ownerId = o;
	}
	
	public Organization(int orgid, String orgname, String termsandconditions, String privacypolicy, String logourl)
	{
		orgId = orgid;
		orgName = orgname;
		termsAndConditions = termsandconditions;
		privacyPolicy = privacypolicy;
		logoUrl = logourl;
	}
	
	public int getOrgId()
	{
		return orgId;
	}
	
	public String getOrgName()
	{
		return orgName;
	}
	
	public String getApplicationKey()
	{
		return applicationKey;
	}
	
	public String getIpAddress()
	{
		return ipAddress;
	}
	
	public int getOwnerId()
	{
		return ownerId;
	}

	public String getTermsAndConditions()
	{
		return termsAndConditions;
	}
	
	public String getPrivacyPolicy()
	{
		return privacyPolicy;
	}

	public String getLogoUrl()
	{
		return logoUrl;
	}
}
