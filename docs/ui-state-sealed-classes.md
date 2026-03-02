# Representando estados da UI com sealed classes no Dart

Uma das decisões mais importantes ao construir interfaces reativas é: **como representar os diferentes estados que uma tela pode ter?** Neste artigo vamos explorar um padrão simples, seguro e elegante usando sealed classes do Dart 3.

---

## O problema dos booleanos soltos

A abordagem mais intuitiva para iniciantes é usar campos booleanos separados:

```dart
bool isLoading = false;
bool hasError = false;
String? errorMessage;
String? token;
```

Parece razoável, mas cria um problema sutil: esses campos são **independentes entre si**, então nada no compilador impede combinações inválidas como:

```dart
isLoading = true;
hasError = true; // qual dos dois vence na UI?
token = "abc";   // como tem token se ainda está carregando?
```

Quanto mais campos, mais combinações impossíveis surgem — e mais `if`s você precisa escrever para cobrir casos que nunca deveriam existir.

---

## Estados são mutuamente exclusivos

Pense em uma tela de login. Em qualquer momento ela está em **exatamente um** desses estados:

- **Inicial** — aguardando o usuário agir
- **Carregando** — requisição em andamento
- **Sucesso** — autenticação concluída com um token
- **Erro** — algo deu errado com uma mensagem

Nunca dois ao mesmo tempo. Isso é exclusividade mútua, e é exatamente o que sealed classes modelam.

---

## Sealed classes no Dart 3

Uma sealed class é uma classe que só pode ser estendida dentro do próprio arquivo. O compilador conhece todos os subtipos possíveis e pode verificar exaustividade.

```dart
sealed class UiState<T> {
  const UiState();
}

class Initial<T> extends UiState<T> {
  const Initial();
}

class Loading<T> extends UiState<T> {
  const Loading();
}

class Success<T> extends UiState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends UiState<T> {
  final String message;
  const Error(this.message);
}
```

O genérico `<T>` permite que cada estado carregue o tipo de dado adequado. Um `Success<String>` carrega um token, um `Success<User>` carrega um objeto de usuário — a estrutura é a mesma.

---

## Consumindo com switch

O `switch` do Dart 3 com sealed classes é **exaustivo**: o compilador garante que todos os subtipos foram tratados.

```dart
switch (uiState) {
  case Initial():
    return FilledButton(onPressed: login, child: Text("Entrar"));
  case Loading():
    return CircularProgressIndicator();
  case Success(:final data):
    return Text("Logado: $data");
  case Error(:final message):
    return Text("Erro: $message");
}
```

Note o `Success(:final data)` — isso é **destructuring**: o valor `data` é extraído diretamente no pattern, sem precisar de cast ou acesso manual. O mesmo vale para `Error(:final message)`.

Se você adicionar um novo subtipo em `UiState` e esquecer de tratá-lo em algum `switch`, o compilador gera um erro. Isso é impossível com booleanos.

---

## Por que usar const nos construtores?

```dart
class Initial<T> extends UiState<T> {
  const Initial(); // ← const aqui
}
```

Sem `const`, não é possível usar `Initial()` como valor padrão em construtores de outras classes:

```dart
class LoginState {
  final UiState<String> uiState;

  // só funciona porque Initial() é const
  const LoginState({this.uiState = const Initial()});
}
```

Além disso, instâncias `const` idênticas são reutilizadas pelo Dart em vez de criar novos objetos — o que é mais eficiente.

---

## Adicionando estados extras

O `UiState` pode ser expandido conforme a necessidade. Dois estados úteis em listas e paginação:

```dart
class Empty<T> extends UiState<T> {
  const Empty();
}

class Refreshing<T> extends UiState<T> {
  final T data;
  const Refreshing(this.data);
}
```

- **`Empty`** — a requisição completou, mas não há dados para exibir
- **`Refreshing`** — está atualizando, mas já tem dados anteriores para mostrar (útil para pull-to-refresh sem sumir o conteúdo)

---

## Independente do gerenciador de estado

O `UiState` é um padrão de modelagem — ele não depende de nenhuma lib específica. Funciona com qualquer abordagem:

```dart
// Com ChangeNotifier
class ListViewModel extends ChangeNotifier {
  UiState<List<Product>> _state = const Initial();
}

// Com Riverpod
class ListViewModel extends Notifier<UiState<List<Product>>> {
  @override
  UiState<List<Product>> build() => const Initial();
}

// Com BLoC
class ListCubit extends Cubit<UiState<List<Product>>> {
  ListCubit() : super(const Initial());
}
```

O que muda é o mecanismo de notificação — o estado em si é sempre o mesmo.

---

## Conclusão

Sealed classes transformam estados de UI em algo que o compilador pode verificar. Em vez de booleanos soltos que permitem combinações inválidas, você tem tipos que representam exatamente o que pode acontecer — nem mais, nem menos.

O padrão é simples de implementar, funciona com qualquer gerenciador de estado e elimina toda uma categoria de bugs que só aparecem em tempo de execução.
