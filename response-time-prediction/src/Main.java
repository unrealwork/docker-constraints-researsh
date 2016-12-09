import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Logger;

public class Main {
    public static final Logger LOGGER = Logger.getLogger(Main.class.getName());

    public static double predictTime(double time, int coreCount, int streesedCores, double averageCoreUsage) {
        Double result = time * coreCount / (coreCount - streesedCores + streesedCores / (1 + 1 / averageCoreUsage));
        Double delta = result - time;
        Double coef = 1 + streesedCores * (averageCoreUsage - 1 / coreCount);
        return time + delta / coef;
    }

    public static void main(String[] args) {
        Properties prop = new Properties();
        InputStream input = null;
        String filename = "config.properties";

        try {
            input = Main.class.getClassLoader().getResourceAsStream(filename);
            prop.load(input);
            int n = Integer.parseInt(prop.getProperty("cores_count"));
            double avgCpuUsage = Double.parseDouble(prop.getProperty("core_usage"));
            double time = Double.parseDouble(prop.getProperty("time"));
            if (input == null) {
                String error = "Can't open file" + filename;
                LOGGER.severe(error);
                return;
            }
            for (int i = 0; i <= n; i++) {
                LOGGER.info(
                        String.format(
                                "Stressed cores: %d - Predicted time: %f",
                                i, predictTime(time, n, i, avgCpuUsage)
                        )
                );
            }
        } catch (IOException e) {
            LOGGER.severe("Failed to read propeerties  file!" + filename);
        }

    }
}
