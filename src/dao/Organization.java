package src.dao;

public class Organization 
{

	private int orgId;
	private String orgName;
	private int ownerId;
	
	public Organization() {}
	
	public Organization(int orgid, String orgname, int o)
	{
		orgId = orgid;
		orgName = orgname;
		ownerId = o;
	}
	
	public int getOrgId()
	{
		return orgId;
	}
	
	public String getOrgName()
	{
		return orgName;
	}
	
	public int getOwnerId()
	{
		return ownerId;
	}

}
