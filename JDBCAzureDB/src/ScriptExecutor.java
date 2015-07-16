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
							System.out.println("Skipping \"GO\"...");
							System.out.println("---------------");
							System.out.println("Query added:\n" + builder);
							System.out.println("---------------");
							builder = "";
							
						}
						else
						{
							builder = builder + line + '\n';
						}
						System.out.println('\n');
					}
					else
					{
						System.out.println("Line is comment, skipping...");
						System.out.println('\n');
					}
				}
				
				System.out.println('\n');
				System.out.println("Start executing queries...");
				System.out.println('\n');
				
				
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
