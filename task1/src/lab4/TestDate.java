package lab4;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.atomic.AtomicInteger;

public class TestDate {
    private static final DateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static final String SAMPLE = "2014-11-15 12:30:45";

    public String getDate() {
        return format.format(new Date());
    }

    public static void main(String[] args) throws InterruptedException {
        System.out.println(new TestDate().getDate());
        // проверка: общий экземпляр формата используют 8 потоков одновременно
        AtomicInteger errors = new AtomicInteger();
        Runnable task = () -> {
            for (int k = 0; k < 10000; k++) {
                try {
                    if (!SAMPLE.equals(format.format(format.parse(SAMPLE)))) errors.incrementAndGet();
                } catch (Exception e) {
                    errors.incrementAndGet();
                }
            }
        };
        Thread[] threads = new Thread[8];
        for (int i = 0; i < threads.length; i++) {
            threads[i] = new Thread(task);
            threads[i].start();
        }
        for (Thread t : threads) t.join();
        System.out.println("Ошибок при работе в 8 потоках: " + errors + " из 80000");
    }
}
