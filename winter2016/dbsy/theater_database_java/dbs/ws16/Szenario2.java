package dbs.ws16;

import java.sql.*;
import java.util.*;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Map.Entry;

import dbs.DBConnector;

public class Szenario2 {

    private Connection connection = null;
    private PreparedStatement pstmt_updateTicket = null;

    
    public static void main(String[] args) throws NumberFormatException, Exception {
        if (args.length == 8) {
            /*
             * args[0] ... server, 
             * args[1] ... port,
             * args[2] ... database, 
             * args[3] ... username, 
             * args[4] ... password,
             * args[5] ... Kunde pid,
             * args[6] ... Auffuehrung aid,
             * args[7] ... AnzTickets
             */

            Connection conn = null;

            
            conn = DBConnector.getConnection(args[0], args[1], args[2], args[3], args[4]);


            if (conn != null) {
                Szenario2 s = new Szenario2(conn);

                s.prepareStatements();
                System.out.println(s.buyTickets(Integer.parseInt(args[5]),Integer.parseInt(args[6]),Integer.parseInt(args[7])));

                conn.close();
            }
        } 
        else {
            System.err.println("Ungueltige Anzahl an Argumenten!");
        }
    }

	public Szenario2(Connection connection) {
        this.connection = connection;
    }
	
	public void prepareStatements() throws SQLException {
		//TODO Create PreparedStatement here
		pstmt_updateTicket = connection.prepareStatement(
		        "UPDATE ticket " +
                        "SET kunde = ? " +
                        "WHERE tid IN (" +
                            "SELECT tid FROM ticket WHERE kunde IS NULL AND auffuehrung = ? LIMIT ?)" +
                        "RETURNING preis");
	}
	

    /*
     * Fuer den Kunden/die Kundin mit der pid knr fuer die Auffuehrung aid anzTickets kaufen sofern verfuegbar
     */
    public double buyTickets(int knr, int aid, int anzTickets) throws Exception {
    	// TODO Write your code here

        // 1. check if there are enough tickets available
        Statement checkAvailabilityStmt = connection.createStatement();
        ResultSet availabilityResult = checkAvailabilityStmt.executeQuery("SELECT COUNT(*) AS availableTickets FROM ticket WHERE kunde IS NULL and auffuehrung = " + aid);

        int availableTickets;
        if (availabilityResult.next()) {
            availableTickets = availabilityResult.getInt("availableTickets");
        } else {
            throw new SQLDataException("Could not estimate available ticket count from tickets table");
        }

        availabilityResult.close();
        checkAvailabilityStmt.close();

        if (availableTickets >= anzTickets) {
            pstmt_updateTicket.setInt(1, knr);
            pstmt_updateTicket.setInt(2, aid);
            pstmt_updateTicket.setInt(3, anzTickets);

            pstmt_updateTicket.execute();

            ResultSet affectedRows = pstmt_updateTicket.getResultSet();

            double summe = 0;
            int numTicketsSold = 0;

            while (affectedRows.next()) {
                numTicketsSold++;
                summe += affectedRows.getDouble("preis");
            }

            if (numTicketsSold != anzTickets) {
                connection.rollback();

                throw new SQLDataException("Update failed, only " + numTicketsSold + " tickets would've been changed, rolling back..");
            }

            pstmt_updateTicket.close();
            affectedRows.close();
            connection.commit();

            return summe;
        } else {
            throw new SQLDataException("Not enough tickets are currently available");
        }
    }
}
