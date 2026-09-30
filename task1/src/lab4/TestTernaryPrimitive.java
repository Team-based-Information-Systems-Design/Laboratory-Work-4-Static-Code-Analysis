package lab4;

public class TestTernaryPrimitive {
    private final double[] vals = new double[] {1.0, 2.0, 3.0};

    double getVal(int idx) {
        return (idx < 0 || idx >= vals.length) ? null : vals[idx];
    }

    public static void main(String[] args) {
        TestTernaryPrimitive t = new TestTernaryPrimitive();
        System.out.println("getVal(1) = " + t.getVal(1));
        System.out.println("getVal(5) = " + t.getVal(5));
    }
}
