package lab4;

public class TestTernarySimpleNull {
    public static void main(String[] args) {
        boolean flag = args.length > 0;
        Integer n = flag ? 1 : null;
        System.out.println("n = " + n);
    }
}
