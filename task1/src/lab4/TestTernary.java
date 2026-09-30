package lab4;

public class TestTernary {
    public static void main(String[] args) {
        boolean flag = args.length == 0;
        Number n = flag ? new Integer(1) : new Double(2.0);
        System.out.println("Класс результата: " + n.getClass().getSimpleName() + ", значение: " + n);
    }
}
