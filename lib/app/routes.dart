enum Routes {
  login('/login'),
  expenseList('/expense-list');

  final String name;

  const Routes(this.name);
}
