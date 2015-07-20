package src.dao;

public class Organization 
{

	private int orgId;
	private String orgName;
	private String applicationKey;
	private String ipAddress;
	private int owner;
	public Organization() 
	{}
	
	public Organization(int orgid, String orgname, String applicationkey, String ipaddress, int o)
	{
		orgId = orgid;
		orgName = orgname;
		applicationKey = applicationkey;
		ipAddress = ipaddress;
		owner = o;
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
	
	public int getOwner()
	{
		return owner;
	}

}
