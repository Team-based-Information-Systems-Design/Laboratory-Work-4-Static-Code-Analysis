package lab4;

public class TestTernaryNull {
    public static void main(String[] args) {
        boolean flag1 = args.length > 0;
        boolean flag2 = args.length > 1;
        Integer n = flag1 ? 1 : flag2 ? 2 : null;
        System.out.println("n = " + n);
    }
}
