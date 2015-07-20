package src;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;

public class PasswordBuilder {
	public static PasswordCredential buildCredential (String password) throws NoSuchAlgorithmException, InvalidKeySpecException
	{
		return new PasswordCredential(PasswordHash.createHash(password));
	}
}
