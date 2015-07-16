package src;

import java.util.*;
import java.io.*;
import java.lang.*;
import java.sql.*;

class ScriptExecutor 
{
	public static boolean executeScript(Statement statement, String dbName)
	{
		List<String> queries = new ArrayList<String>();
		
<<<<<<< HEAD
		BufferedReader br = new BufferedReader(new FileReader("~/Documents/JDBCAzureDB/JDBCAzureDB/script.sql"));
		
=======
>>>>>>> origin/master
		try
		{
			BufferedReader br = new BufferedReader(new FileReader("out.txt"));
			String builder = "";
			String line;
		    while ((line = br.readLine()) != null) 
		    {
		    	if (line == "GO")
		    	{
		    		queries.add(builder);
		    		builder = "";
		    	}
		    	else
		    	{
		    		builder = builder + line + '\n';
		    	}
		    }
		    for (String query : queries)
		    {
		    	statement.executeUpdate(query);
		    }
		    br.close();
		    return true;
		}
		catch (Exception e) 
		{
			System.out.println(e);
			//br.close();
			return false;
		}
		finally
		{
			//br.close();
		}
	}
}
