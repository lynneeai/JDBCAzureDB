package src;

public class PasswordCredential
{
    private final SaltedHash _password;

    public PasswordCredential(SaltedHash password)
    {
        _password = password;
    }

    public SaltedHash getPassword()
    {
    	return _password;
    }
    
    @Override
    public String toString()
    {
    	String ret = "";
    	String salt = _password.getSalt();
    	String iterations = String.valueOf(_password.getIterations());
    	String hash = _password.getHash();
    	
    	ret = "{salt:\""+salt+"\",iterations:"+iterations+",hash:\""+hash+"\"}";
    	return ret;
    }
}