package dbs;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;

public class DBConnector {
    public static Connection getConnection(String host, String port, String database) {
        Connection conn = null;
        
        String driver = "jdbc:postgresql";
        
        String dbConnectionString = 
            driver + "://" + host + ":" + port + "/" + database;
        
        try {
            Class.forName("org.postgresql.Driver");
            
            conn = DriverManager.getConnection(dbConnectionString);
            
            conn.setAutoCommit(false);
        } 
        catch (SQLException ex) {
            conn = null;
            
            System.err.println(ex.getMessage());
            System.err.println("Cannot connect to database ...");
        }
        catch (ClassNotFoundException ex) {
            conn = null;
            
            System.err.println("Database driver not available ...");
        }
        
        return conn;
    }
    
    public static Connection getConnection(String host, String port, String database,
                                           String userName, String password) {
        Connection conn = null;
        
        String driver = "jdbc:postgresql";
        
        String dbConnectionString = 
            driver + "://" + host + ":" + port + "/" + database;
        
        try {
            Class.forName("org.postgresql.Driver");
            
            conn = DriverManager.getConnection(dbConnectionString, 
                                               userName, password);
            
            conn.setAutoCommit(false);
        } 
        catch (SQLException ex) {
            conn = null;
            
            System.err.println("Cannot connect to database ...");
        }
        catch (ClassNotFoundException ex) {
            conn = null;
            
            System.err.println("Database driver not available ...");
        }
        
        return conn;
    }
}