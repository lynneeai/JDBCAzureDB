package src.dao;

public class InterceptorId {
	String intSerial;
	String embeddedId;
	boolean key;
	
	public InterceptorId(String intSerial, String embeddedId, boolean key) {
		this.intSerial = intSerial;
		this.embeddedId = embeddedId;
		this.key = key;
	}

	public String getIntSerial()
	{
		return this.intSerial;
	}
	
	public String getEmbeddedId()
	{
		return this.embeddedId;
	}
	
	public boolean getKey()
	{
		return this.key;
	}
}
