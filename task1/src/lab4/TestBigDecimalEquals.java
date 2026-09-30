package lab4;

import java.math.BigDecimal;

public class TestBigDecimalEquals {
    public static void main(String[] args) {
        BigDecimal d1 = new BigDecimal("1.1");
        BigDecimal d2 = new BigDecimal("1.10");
        System.out.println(d1.equals(d2));
    }
}
