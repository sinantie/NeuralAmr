package util.apps;

import java.io.IOException;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import util.server.NamedEntityRecognizerClient;
import util.server.NerServer;

/**
 *
 * @author ikonstas
 */
public class AmrUtilsTest {

    public static class RunServer extends Thread {

        @Override
        public void run() {
            try {
                NerServer.main(new String[]{});
            } catch (IOException e) {
                e.printStackTrace(System.err);
            }
        }
    }

    public AmrUtilsTest() {
    }

    @BeforeClass
    public static void setUpClass() {
        try {
            // start NER server
            RunServer nerServer = new RunServer();
            nerServer.start();
            // wait for server to initialize
            Thread.sleep(4000l);
        } catch (InterruptedException ex) {
            ex.printStackTrace(System.err);
        }
    }

    @AfterClass
    public static void tearDownClass() {
        try {
            // terminate NER server
            NamedEntityRecognizerClient client = new NamedEntityRecognizerClient(4444);
            client.processToString("terminate_server");
        } catch (IOException ex) {
            ex.printStackTrace(System.err);
        }
    }

    @Before
    public void setUp() {
    }

    @After
    public void tearDown() {

    }

    /**
     * Test of main method, of class AmrUtils.
     */
    @Test
    public void testAnonymizeFull() {
        System.out.println("testAnonymizeFull");
        String input = "(h / hold-04 :ARG0 (p2 / person :ARG0-of "
                + "(h2 / have-org-role-91 :ARG1 (c2 / country :name (n3 / name :op1 \"United\" :op2 \"States\")) "
                + ":ARG2 (o / official)))  :ARG1 (m / meet-03 :ARG0 (p / person  "
                + ":ARG1-of (e / expert-01) :ARG2-of (g / group-01))) "
                + ":time (d2 / date-entity :year 2002 :month 1) :location (c / city  :name (n / name :op1 \"New\" :op2 \"York\")))";
        String[] args = {"anonymizeAmrFull", "false", input};
        AmrUtils.main(args);
    }

    @Test
    public void testAnonymizeStripped() {
        System.out.println("testAnonymizeStripped");
        String input = "help :arg0 (person :name \"Mr. T\") :arg1 ( save :arg0 world ) :time ( date-entity :year 2016 :month 3 :day 4)";
        String[] args = {"anonymizeAmrStripped", "false", input};
        AmrUtils.main(args);
    }

    @Test
    public void testDeAnonymize() {
        System.out.println("testDeAnonymize");
        String sent = "person_name_0 helped save num_0 cats in day_date-entity_0 month_name_date-entity_0 year_date-entity_0 .";
        String alignments = "person_name_0|||name_John_Pappas\tnum_0|||3\tyear_date-entity_0|||2016\tmonth_date-entity_0|||3\tday_date-entity_0|||4";
        String[] args = {"deAnonymizeText", "false", sent + "#" + alignments};
        AmrUtils.main(args);
    }

//    @Test
    public void testAnonymizeFullFileAmr() {
        System.out.println("testAnonymizeFullFileAmr");
        String input = "resources/sample-data/sample-amr.txt";
        String[] args = {"anonymizeAmrFull", "true", input};
        AmrUtils.main(args);
    }

//    @Test
    public void testDeAnonymizeFullFile() {
        System.out.println("testDeAnonymizeFullFile");
        String input = "resources/sample-data/sample-amr.txt";
        String[] args = {"deAnonymizeText", "true", input};
        AmrUtils.main(args);
    }

    @Test
    public void testNerAnonymize() {
        System.out.println("testNerAnonymize");
        String sent = "John Watson likes to generate complex graphs in Barcelona on 17 May 2017.";
        String[] args = {"anonymizeText", "false", sent};
        AmrUtils.main(args);
    }

    @Test
    public void testAmrDeAnonymize() {
        System.out.println("testAmrDeAnonymize");
        String amr = "meet-01 :polarity - :arg0 person_name_0 :location country-region_name_2 :arg1 ( man :quant num_0) :frequency ( rate-entity :arg2 ( temporal-quantity temporal-quantity_num_0 :unit year )  ) :arg2 ( stage :ord ( ordinal-entity ordinal-entity_num_1 )) :time ( date-entity year_date-entity_0 month_date-entity_0 day_date-entity_0 )";
        String alignments = "ordinal-entity_num_1|||3\tnum_0|||1000\tperson_name_0|||name_John_Pappas\tperson_name_1|||name_George_Benson\tcountry-region_name_3|||Attica\tday_date-entity_0|||25\tyear_date-entity_0|||2017\tmonth_name_date-entity_0|||4\ttemporal-quantity_num_0|||1";
        String[] args = {"deAnonymizeAmr", "false", amr + "#" + alignments};
        AmrUtils.main(args);
    }

//    @Test
    public void testAnonymizeFileText() {
        System.out.println("testAnonymizeFileText");
        String input = "resources/sample-data/sample-nl.txt";

        String[] args = {"anonymizeText", "true", input};
        AmrUtils.main(args);
    }

//    @Test
    public void testDeAnonymizeAmrFile() {
        System.out.println("testDeAnonymizeAmrFile");
        String input = "resources/sample-data/sample-nl.txt";

        String[] args = {"deAnonymizeAmr", "true", input};
        AmrUtils.main(args);
    }

}
