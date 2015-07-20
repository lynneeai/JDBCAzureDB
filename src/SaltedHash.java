package src;

public class SaltedHash
{
	private final int _iterations;
	private final byte[] _salt;
	private final byte[] _hash;

	public SaltedHash(byte[] salt, int iterations, byte[] hash)
	{
		_salt = salt;
		_iterations = iterations;
		_hash = hash;
	}

	public byte[] getSalt()
	{
		return _salt;
	}

	public int getIterations()
	{
		return _iterations;
	}

	public byte[] getHash()
	{
		return _hash;
	}

	protected boolean equals(SaltedHash other)
	{
		return _salt.equals(other._salt) && _iterations == other._iterations && _hash.equals(other._hash);
	}

	@Override
	public boolean equals(Object obj)
	{
		if (null == obj) return false;
		if (this == obj) return true;
		if (obj.getClass() != this.getClass()) return false;
		return equals((SaltedHash) obj);
	}

	public int GetHashCode()
	{
		int hashCode = (_salt != null ? _salt.hashCode() : 0);
		hashCode = (hashCode*397) ^ _iterations;
		hashCode = (hashCode*397) ^ (_hash != null ? _hash.hashCode() : 0);
		return hashCode;
	}
}