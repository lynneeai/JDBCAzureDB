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
}