//package src;

import java.util.*;
import java.io.*;
import java.sql.*;

class ScriptExecutor 
{
	public static boolean executeScript(Statement statement, String dbName)
	{
		List<String> queries = new ArrayList<String>();


		BufferedReader br;
		try {
			br = new BufferedReader(new FileReader("out.txt"));

			try
			{
				String builder = "";
				String line;
				while ((line = br.readLine()) != null) 
				{
					System.out.println("Next Line:");
					System.out.println(line);
					if (!line.startsWith("/*") && !line.startsWith("﻿/"))
					{
						if (line.equals("GO"))
						{
							queries.add(builder);
							builder = "";
						}
						else
						{
							builder = builder + line + '\n';
						}
						System.out.println("Query build:");
						System.out.println(builder);
						System.out.println('\n');
					}
					else
					{
						System.out.println("Line is comment, skipping...\n");
					}
				}
				for (String query : queries)
				{
					System.out.println("Executing Query:");
					System.out.println(query);
					System.out.println("---------------");
					statement.executeUpdate(query);
				}
				br.close();
				return true;
			}
			catch (Exception e) 
			{
				System.out.println(e);
				br.close();
				return false;
			}
			finally
			{
				br.close();
			}
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return false;
		}
		catch (IOException i)
		{
			i.printStackTrace();
			return false;
		}
	}
}
