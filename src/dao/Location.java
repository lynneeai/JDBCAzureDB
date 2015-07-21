package src.dao;

public class Location {

	private int locId;
	private String locDesc;
	private int orgId;
	private String unitSuite;
	private String street;
	private String city;
	private String state;
	private String country;
	private String postalCode;
	private String latitude;
	private String longitude;
	private String locType;
	private String locSubType;
	
	public Location() {}
	public Location(int locid, String locdesc, int orgid, String unitsuite, String Street, String City, String State, String Country, String postalcode, String Latitude, String Longitude, String loctype, String locsubtype)
	{
		locId = locid;
		locDesc = locdesc;
		orgId = orgid;
		unitSuite = unitsuite;
		street = Street;
		city = City;
		state = State;
		country = Country;
		postalCode = postalcode;
		latitude = Latitude;
		longitude = Longitude;
		locType = loctype;
		locSubType = locsubtype;
	}
	
	public int getLocId()
	{
		return locId;
	}
	
	public String getLocDesc()
	{
		return locDesc;
	}
	
	public int getOrgId()
	{
		return orgId;
	}
	
	public String getUnitSuite()
	{
		return unitSuite;
	}
	
	public String getStreet()
	{
		return street;
	}

	public String getCity()
	{
		return city;
	}
	
	public String getState()
	{
		return state;
	}
	
	public String getCountry()
	{
		return country;
	}
	
	public String getPostalCode()
	{
		return postalCode;
	}

	public String getLatitude()
	{
		return latitude;
	}
	
	public String getLongitude()
	{
		return longitude;
	}
	
	public String getLocType()
	{
		return locType;
	}
	
	public String getLocSubType()
	{
		return locSubType;
	}

}
