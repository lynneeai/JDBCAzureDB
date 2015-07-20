package src;

import java.util.*;
import java.io.*;
import java.sql.*;

class ScriptExecutor 
{
	public static boolean executeScript(Statement statement, String scriptName)
	{
		List<String> queries = new ArrayList<String>();


		BufferedReader br;
		try {
	        final String dir = System.getProperty("user.dir");
	        System.out.println("current dir = " + dir);
			FileInputStream is = new FileInputStream(scriptName +".sql");
			InputStreamReader isr = new InputStreamReader(is, "UTF-16LE");
			br = new BufferedReader(isr);

			try
			{
				String builder = "";
				String line;
				boolean multilineComment = true;
				while ((line = br.readLine()) != null) 
				{
					if (multilineComment == true)
					{
						if (!line.contains("*/"))
						{
							//Skip line
						}
						else
						{
							multilineComment = false;
						}
					}
					else
					{
						System.out.println("Next Line:");
						System.out.println(line);
						if (!line.startsWith("/*"))
						{
							if (!line.contains("--") && !line.contains("/*"))
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
							}
							else
							{
								int index = 0;
								if (line.contains("/*") && !line.startsWith("--"))
								{
									index = line.indexOf("/*");
									if (!line.contains("*/"))
									{
										System.out.println("Multiline comment");
										multilineComment = true;
									}
								}
								else
								{
									if (!line.startsWith("--"))
									{
										index = line.indexOf("--");
										System.out.println(line.substring(0,index));
										//System.in.read();
									}
								}
								
								builder = builder + line.substring(0,index) + '\n';
							}
						}
						else
						{
							System.out.println("Line is comment, skipping...");
							if (!line.contains("*/"))
							{
								System.out.println("Multiline comment");
								multilineComment = true;
							}
						}
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
