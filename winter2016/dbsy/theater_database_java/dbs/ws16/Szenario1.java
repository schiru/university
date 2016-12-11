package dbs.ws16;

import dbs.DBConnector;

import java.sql.*;
import java.util.HashMap;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.io.IOException;

public class Szenario1 {

    private Connection connection = null;

    public static void main(String[] args) throws Exception {
        if (args.length <= 6 && args.length >= 4) {
            /*
             * args[0] ... type -> [a|b], 
             * args[1] ... server, 
             * args[2] ... port,
             * args[3] ... database, 
             * args[4] ... username, 
             * args[5] ... password
             */

            Connection conn = null;

            if (args.length == 4) {
                conn = DBConnector.getConnection(args[1], args[2], args[3]);
            }
            else {
                if (args.length == 5) {
                    conn = DBConnector.getConnection(args[1], args[2], args[3], args[4], "");
                }
                else {
                    conn = DBConnector.getConnection(args[1], args[2], args[3], args[4], args[5]);
                }
            }

            if (conn != null) {
                conn.setAutoCommit(false);
                Szenario1 s = new Szenario1(conn);

                if (args[0].equals("a")) {
                    s.runTransactionA();
                }
                else {
                    s.runTransactionB();
                }

                try {
                    conn.close();
                } catch (SQLException ex) {
                    Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
        }
        else {
            System.err.println("Ungueltige Anzahl an Argumenten!");
        }
    }

    public Szenario1(Connection connection) {
        this.connection = connection;
    }

    /*
     * Beschreibung siehe Angabe
     */
    public void runTransactionA() {
        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */



        wait("Druecken Sie <ENTER> zum Starten der Transaktion ...");
        /*
         * ################################################################################
         */

        System.out.println("Transaktion A Start");

        
        /*
         * Setzen Sie das aus Ihrer Sicht passende Isolation-Level:
         */

        try {
            connection.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);

        /*
         * Abfrage 1:
         * Anzahl der verkauften Tickets pro Auffuehrung
         */
            Statement stmt = connection.createStatement();
            ResultSet result = stmt.executeQuery("SELECT auffuehrung, count(auffuehrung) AS verkauft FROM ticket WHERE kunde IS NOT NULL GROUP BY auffuehrung;");

       /*
        * Ausgeben der Anzahl der verkauften Tickets pro Auffuehrung
        */

            if (!result.next()) {
                System.out.println("Es wurden noch keine Tickets verkauft.");
            } else {
                do {
                    System.out.printf("Auffuehrung: %d, verkaufte Tickets: %d\n", result.getInt("auffuehrung"), result.getInt("verkauft"));
                } while (result.next());
            }

            result.close();
            stmt.close();
            
        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
            wait("Druecken Sie <ENTER> zum Fortfahren ...");
        /*
         * ################################################################################
         */
        
        /*
         * Abfrage 2:
         * Anzahl der verkauften Tickets
         */

            stmt = connection.createStatement();
            result = stmt.executeQuery("SELECT count(*) AS verkauft FROM ticket WHERE kunde IS NOT NULL;");

            if (result.next()) {
                System.out.printf("Insgesamt verkaufte Tickets: %d\n", result.getInt("verkauft"));
            }

            result.close();

        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
            wait("Druecken Sie <ENTER> zum Beenden der Transaktion ...");
        /*
         * ################################################################################
         */

            stmt.close();
            connection.commit();

        }
        catch (SQLException ex) {
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }

        /*
         * Beenden Sie die Transaktion
         */

        System.out.println("Transaktion A Ende");
    }

    public void runTransactionB() throws Exception {
        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
        wait("Druecken Sie <ENTER> zum Starten der Transaktion ...");

        System.out.println("Transaktion B Start");

        try {
            Statement stmt = connection.createStatement();
            int tid = -1;
            int kid = -1;

            ResultSet rs1 = stmt.executeQuery("SELECT * FROM Ticket WHERE kunde IS NULL");
            if (rs1.next()) {
                tid = rs1.getInt("tid");
            }
            rs1.close();

            if (tid == -1)
                throw new Exception("No Ticket found!");

            rs1 = stmt.executeQuery("SELECT * FROM kunde;");
            if (rs1.next()) {
                kid = rs1.getInt("pid");
            }
            rs1.close();

            if (kid == -1)
                throw new Exception("No Kunde found!");


            stmt.executeUpdate("UPDATE ticket SET kunde = "+kid+" WHERE tid = " + tid);

            stmt.close();

            System.out.println("Ein Ticket wurde verkauft ...");

            wait("Druecken Sie <ENTER> zum Beenden der Transaktion ...");

            connection.commit();

            wait("Druecken Sie <ENTER> zum Beenden des Szenarios ...");
            stmt = connection.createStatement();
            stmt.executeUpdate("UPDATE ticket SET kunde = NULL WHERE tid = " + tid);
            stmt.close();
            connection.commit();

        }
        catch (SQLException ex) {
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }

        System.out.println("Transaktion B Ende");
        /*
         * ################################################################################
         */
    }

    private static void wait(String message) {
        /* 
         * Vorgegebener Codeteil 
         * ################################################################################
         */
        System.out.println(message);
        Scanner scanner = new Scanner(System.in);
        scanner.nextLine();
         /*
         * ################################################################################
         */
    }

}
