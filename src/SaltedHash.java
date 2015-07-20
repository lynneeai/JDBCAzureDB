package src;

public class SaltedHash
{
	private final int _iterations;
	private final String _salt;
	private final String _hash;

	public SaltedHash(String salt, int iterations, String hash)
	{
		_salt = salt;
		_iterations = iterations;
		_hash = hash;
	}

	public String getSalt()
	{
		return _salt;
	}

	public int getIterations()
	{
		return _iterations;
	}

	public String getHash()
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
	
	public String toString()
	{
		return this._iterations + ":" + this._salt + ":" + this._hash;
	}
}