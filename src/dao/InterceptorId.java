package src.dao;

public class InterceptorId 
{
	public String intSerial;
	public String embeddedId;
	public String key;
	
	public InterceptorId() {}
	
	public InterceptorId(String intserial, String embeddedid, String Key)
	{
		intSerial = intserial;
		embeddedId = embeddedid;
		key = Key;
	}
	
	public String getIntSerial()
	{
		return intSerial;
	}
	
	public String getEmbeddedId()
	{
		return embeddedId;
	}
	
	public String getKey()
	{
		return key;
	}
}
