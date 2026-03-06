enum Routes {
  login('/login'),
  register('/register'),
  expenseList('/expense-list');

  final String name;

  const Routes(this.name);
}
