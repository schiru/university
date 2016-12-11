package dbs.ws16;

import java.math.BigDecimal;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.logging.Level;
import java.util.logging.Logger;

import dbs.DBConnector;

public class Szenario3 {

    private Connection connection = null;
    
    public static void main(String[] args) {
        if (args.length <= 5 && args.length >= 3) {
            /*
             * args[1] ... server, 
             * args[2] ... port,
             * args[3] ... database, 
             * args[4] ... username, 
             * args[5] ... password
             */

            Connection conn = null;

            if (args.length == 3) {
                conn = DBConnector.getConnection(args[0], args[1], args[2]);
            } 
            else {
                if (args.length == 4) {
                    conn = DBConnector.getConnection(args[0], args[1], args[2], args[3], "");
                } 
                else {
                    conn = DBConnector.getConnection(args[0], args[1], args[2], args[3], args[4]);
                }
            }

            if (conn != null) {
                Szenario3 s = new Szenario3(conn);

                s.run();
            }

        } 
        else {
            System.err.println("Ungueltige Anzahl an Argumenten!");
        }
    }

	public Szenario3(Connection connection) {
        this.connection = connection;
    }

	/*
     * Jede/n Kuenstler/in abrechnen
     */
    public void run() {
        try {
            // 1. prepare callable statement
            CallableStatement abrechnen = connection.prepareCall("{CALL abrechnen(?, ?)}");

            java.sql.Date date = new Date(Calendar.getInstance().getTimeInMillis());
            abrechnen.setDate(2, date);

            abrechnen.registerOutParameter(1, Types.NUMERIC);

            // 2. fetch artist ids
            ResultSet artistResults = connection.createStatement().executeQuery("SELECT vname, nname, pid FROM kuenstler NATURAL JOIN Person;");
            BigDecimal sumOfSalaries = new BigDecimal(0);
            sumOfSalaries.setScale(8);

            String today = new SimpleDateFormat("dd.MM.yyyy").format(Calendar.getInstance().getTime());
            System.out.printf("Berechnete Gagen (bis %s):\n\n", today);

            while (artistResults.next()) {
                // Set first param of abrechnen-call to the artist-id
                abrechnen.setInt(1, artistResults.getInt("pid"));

                abrechnen.execute();

                // This is the Java mapping for NUMERIC
                // source: https://www.cis.upenn.edu/~bcpierce/courses/629/jdkdocs/guide/jdbc/getstart/mapping.doc.html
                BigDecimal salary = abrechnen.getBigDecimal(1);
                sumOfSalaries = sumOfSalaries.add(salary);

                String name = String.format("%s, %s", artistResults.getString("nname"), artistResults.getString("vname"));
                System.out.printf("\t%-20s\t%.2f\n", name + ":", salary);
            }

            System.out.println("\t--------------------------------");
            System.out.printf("%25s:\t%.2f\n", "SUMME", sumOfSalaries);

            artistResults.close();
            abrechnen.close();

            connection.commit();
        } catch (SQLException ex) {
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

}
