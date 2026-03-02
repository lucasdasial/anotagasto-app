# Gerenciamento de Estado no Flutter: de ChangeNotifier + Provider ao Riverpod

Quando começamos a construir aplicativos Flutter que precisam reagir a mudanças de dados, rapidamente nos deparamos com uma pergunta: **como fazer a UI atualizar quando o estado muda?** Neste artigo vamos explorar essa jornada, começando pelo `ChangeNotifier` + `Provider` e entendendo como o Riverpod resolve as mesmas dores de forma mais elegante.

Os exemplos seguirão o padrão **MVVM (Model-View-ViewModel)**, por ser uma arquitetura bem estabelecida e natural no contexto de Flutter reativo. A separação fica assim:

- **Model** — repositórios e serviços, responsáveis pelos dados e regras de negócio
- **ViewModel** — gerencia o estado da UI e orquestra chamadas ao Model
- **View** — apenas renderiza o que a ViewModel expõe, sem lógica própria

Essa separação tem um benefício direto: a ViewModel pode ser testada de forma isolada, sem depender de widgets ou do framework de UI. É exatamente esse isolamento que torna a combinação MVVM + Riverpod tão poderosa — e que veremos ao longo do artigo.

---

## Pré-requisito: UiState com sealed classes

Todos os exemplos deste artigo utilizam o padrão `UiState` — uma forma de representar os estados de uma tela (inicial, carregando, sucesso, erro) usando sealed classes do Dart 3, garantindo exclusividade de estado e verificação em compile time.

Se você ainda não conhece o padrão, recomendo ler primeiro: [Representando estados da UI com sealed classes no Dart](./ui-state-sealed-classes.md)

---

## O problema: UI que reage a dados

Imagine uma tela de login. Ela precisa mostrar um botão no estado inicial, um loading enquanto autentica, e uma mensagem de sucesso ou erro ao finalizar. Precisamos de uma forma de representar esses estados e notificar a UI quando eles mudam.

---

## ChangeNotifier + Provider

O `ChangeNotifier` é uma classe do próprio Flutter. A ideia é simples: você estende ela na sua ViewModel, chama `notifyListeners()` quando o estado muda, e os widgets que estão ouvindo são reconstruídos.

```dart
class LoginViewModel extends ChangeNotifier {
  UiState<String> _state = Initial();
  UiState<String> get state => _state;

  Future<void> login() async {
    _state = Loading();
    notifyListeners();

    await Future.delayed(Duration(seconds: 3)); // Aqui seria chamada a um endpoint de autenticação que retornaria um token de acesso do usuário
    final token = "token:example"
    _state = Success(token);
    notifyListeners();
  }
}
```

Para disponibilizar a ViewModel na árvore de widgets, usamos o `Provider`:

```dart
ChangeNotifierProvider<LoginViewModel>(
  create: (_) => LoginViewModel(),
  child: Consumer<LoginViewModel>(
    builder: (context, vm, child) {
      return switch (vm.state) {
        Initial() => FilledButton(onPressed: vm.login, child: Text("Entrar")),
        Loading() => CircularProgressIndicator(),
        Success(:final data) => Text("Logado com token: $data"),
        Error(:final message) => Text("Erro: $message"),
        _ => SizedBox.shrink(),
      };
    },
  ),
)
```

Funciona bem para casos simples, mas tem limitações que aparecem conforme o projeto cresce.

---

## As limitações do ChangeNotifier + Provider

### 1. notifyListeners() notifica todos

Quando você chama `notifyListeners()`, **todos** os listeners são notificados, independente do que mudou. Se sua ViewModel tem dois campos — `uiState` e `rememberMe` — e você atualiza apenas `rememberMe`, qualquer widget ouvindo a ViewModel inteira vai rebuildar.

A alternativa nativa seria usar `ValueNotifier` + `ValueListenableBuilder` para cada campo:

```dart
class LoginViewModel {
  final uiState = ValueNotifier<UiState<String>>(Initial());
  final rememberMe = ValueNotifier<bool>(false);

  void dispose() {
    uiState.dispose();
    rememberMe.dispose();
  }
}
```

```dart
ValueListenableBuilder<bool>(
  valueListenable: vm.rememberMe,
  builder: (context, value, child) {
    // só rebuilda quando rememberMe mudar
  },
)
```

Funciona, mas o custo é alto: cada campo vira um `ValueNotifier` separado e você precisa gerenciar o `dispose` de cada um manualmente.

O `Provider` oferece o `Selector` como alternativa, mas adiciona mais boilerplate.

### 2. O Provider precisa estar na árvore de widgets

O `ChangeNotifierProvider` precisa ser inserido na árvore de widgets acima de quem o consome. Isso cria um acoplamento entre a lógica de negócio e a estrutura da UI. Em projetos maiores, manter essa hierarquia organizada vira um trabalho extra.

### 3. Testes com dependências exigem injeção manual

Quando sua ViewModel depende de um repositório, você precisa injetar via construtor para conseguir mockar nos testes:

```dart
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  LoginViewModel(this._repository);
}

// no teste
final vm = LoginViewModel(repository: MockAuthRepository());
```

Funciona, mas exige que a classe seja projetada para isso desde o início.

### 4. Injeção de dependências exige uma lib extra

O `Provider` não tem um mecanismo nativo para registrar e resolver dependências encadeadas. Em projetos maiores, é comum recorrer ao `get_it` para preencher essa lacuna:

```dart
// get_it registra as dependências na inicialização do app
GetIt.I.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
GetIt.I.registerFactory<LoginViewModel>(
  () => LoginViewModel(GetIt.I<AuthRepository>()),
);

// Provider usa o get_it para criar a ViewModel com as dependências já resolvidas
ChangeNotifierProvider<LoginViewModel>(
  create: (_) => GetIt.I<LoginViewModel>(),
)
```

Funciona, mas significa adicionar e aprender mais uma biblioteca — cada uma com seu ciclo de vida e configuração próprios.

---

## Riverpod: as mesmas ideias, melhor executadas

O Riverpod foi criado pelo mesmo autor do `Provider` (Remi Rousselet) justamente para resolver essas limitações. A mudança fundamental é que os providers **vivem fora da árvore de widgets** — eles são objetos globais e seguros por tipo. E por ter injeção de dependências embutida, **elimina a necessidade do `get_it`** — tudo fica em um único lugar, com um único ciclo de vida.

### ProviderScope no lugar de ChangeNotifierProvider

Em vez de envolver cada página com seu provider, você envolve o app inteiro uma única vez:

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: const LoginPage(),
      ),
    );
  }
}
```

### Injeção de dependências nativa

Com Riverpod, providers podem depender de outros providers diretamente via `ref` — sem precisar do `get_it`:

```dart
final authRepositoryProvider = Provider((_) => AuthRepositoryImpl());

final loginViewModelProvider = NotifierProvider<LoginViewModel, LoginState>(() {
  final repository = ref.watch(authRepositoryProvider); // ← injeção nativa
  return LoginViewModel(repository);
});
```

O Riverpod resolve a dependência automaticamente, garante a ordem de inicialização e gerencia o ciclo de vida de cada provider.

### Notifier no lugar de ChangeNotifier

O `Notifier` substitui o `ChangeNotifier`. A diferença principal é que em vez de chamar `notifyListeners()`, você simplesmente atribui um novo valor a `state`:

```dart
class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> login() async {
    state = state.copyWith(uiState: Loading());
    await Future.delayed(Duration(seconds: 4));
    state = state.copyWith(uiState: Success("xpto_token"));
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);
```

### Estado como classe imutável com copyWith

Quando a ViewModel tem múltiplos atributos reativos, o padrão é criar uma classe de estado que os agrupa:

```dart
class LoginState {
  final UiState<String> uiState;
  final bool rememberMe;

  const LoginState({
    this.uiState = const Initial(),
    this.rememberMe = false,
  });

  LoginState copyWith({
    UiState<String>? uiState,
    bool? rememberMe,
  }) => LoginState(
    uiState: uiState ?? this.uiState,
    rememberMe: rememberMe ?? this.rememberMe,
  );
}
```

O `copyWith` é essencial aqui. O Riverpod detecta mudanças comparando a **referência** do objeto — não o conteúdo. Então para notificar os widgets, você sempre cria um novo objeto em vez de modificar o existente:

```dart
// ✅ cria novo objeto — Riverpod detecta a mudança
state = state.copyWith(rememberMe: true);

// ❌ modifica o mesmo objeto — Riverpod não detecta
state.rememberMe = true;
```

### select() para rebuilds granulares

Com o estado agrupado em `LoginState`, você controla exatamente o que cada widget observa usando `.select()`:

```dart
// só rebuilda quando uiState mudar
final uiState = ref.watch(loginViewModelProvider.select((s) => s.uiState));

// só rebuilda quando rememberMe mudar
final rememberMe = ref.watch(loginViewModelProvider.select((s) => s.rememberMe));
```

Se `setRememberMe` for chamado, apenas o widget que observa `rememberMe` rebuilda. O restante da tela fica intocado.

### ConsumerWidget no lugar de Consumer

A View fica mais limpa. Em vez de envolver o body com `Consumer`, o widget inteiro vira um `ConsumerWidget`:

```dart
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(loginViewModelProvider.select((s) => s.uiState));
    final rememberMe = ref.watch(loginViewModelProvider.select((s) => s.rememberMe));
    final vm = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("AnotaGasto")),
      body: Center(
        child: switch (uiState) {
          Initial() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(onPressed: vm.login, child: Text("Entrar")),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (v) => vm.setRememberMe(v ?? false),
                    ),
                    Text("Lembrar-me"),
                  ],
                ),
              ],
            ),
          Loading() => CircularProgressIndicator(),
          Success(:final data) => Text("Logado: $data"),
          Error(:final message) => Text("Erro: $message"),
          _ => SizedBox.shrink(),
        },
      ),
    );
  }
}
```

Note o uso de `ref.watch` para observar o estado e `ref.read` para acessar métodos — essa distinção é importante: `ref.watch` dentro do `build` garante o rebuild, `ref.read` é para chamadas pontuais como callbacks de botão.

### Testes com ProviderContainer

Com Riverpod, os testes usam `ProviderContainer` — sem widgets, sem Flutter Test completo:

```dart
void main() {
  test('estado inicial deve ser Initial', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(loginViewModelProvider);
    expect(state.uiState, isA<Initial>());
  });

  test('login deve passar por Loading e chegar em Success', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final states = <UiState<String>>[];
    container.listen(
      loginViewModelProvider.select((s) => s.uiState),
      (_, next) => states.add(next),
    );

    await container.read(loginViewModelProvider.notifier).login();

    expect(states[0], isA<Loading>());
    expect(states[1], isA<Success>());
  });
}
```

E para mockar dependências, o `overrides` dispensa qualquer mudança na ViewModel:

```dart
final container = ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  ],
);
```

---

## Comparativo final

|                        | ChangeNotifier + Provider           | Riverpod                       |
| ---------------------- | ----------------------------------- | ------------------------------ |
| Registro do provider   | na árvore de widgets                | fora da árvore                 |
| Notificação de mudança | `notifyListeners()`                 | atribuição a `state`           |
| Rebuild granular       | `Selector` / `ValueNotifier`        | `.select()`                    |
| Múltiplos estados      | campos separados ou `ValueNotifier` | `copyWith` em classe de estado |
| Testes                 | instância direta + `addListener`    | `ProviderContainer`            |
| Mock de dependências   | injeção via construtor              | `overrides`                    |
| Injeção de dependências | `get_it` ou manual                 | nativa via `ref`               |

---

## Por onde começar?

Se você é iniciante, comece pelo **ChangeNotifier + Provider**.

- **Menos conceitos de uma vez** — você aprende reatividade, ViewModel e separação de responsabilidades sem precisar entender `Notifier`, `ProviderContainer`, `ref.watch` vs `ref.read` e `overrides` ao mesmo tempo
- **Mais próximo do Flutter puro** — `ChangeNotifier` é do próprio Flutter, então você entende o mecanismo antes de usar uma abstração em cima
- **Os problemas fazem sentido depois** — quando você sentir na prática que `notifyListeners()` está rebuildando mais do que deveria, ou que o `ChangeNotifierProvider` na árvore está te atrapalhando, a migração pro Riverpod faz sentido e você entende **por que** cada decisão foi tomada
- **A documentação do Provider é mais acessível** para quem está começando

A ordem natural seria:

```
ChangeNotifier + Provider
       ↓
  sente as limitações
       ↓
     Riverpod
```

Pular direto pro Riverpod é possível, mas você corre o risco de usar sem entender o problema que ele resolve — o que dificulta debugar quando algo dá errado.

---

## Conclusão

O `ChangeNotifier` + `Provider` é uma solução sólida e suficiente para projetos menores. Ele é simples de entender e está bem documentado. Mas conforme o projeto cresce, suas limitações — rebuilds desnecessários, acoplamento com a árvore de widgets, dificuldade de testar com dependências — começam a pesar.

O Riverpod não substitui os conceitos, ele os refina. O `UiState` como sealed class, a ViewModel separada da View, o estado imutável com `copyWith` — tudo isso continua igual. O que muda é a infraestrutura ao redor: mais previsível, mais testável e com controle fino de rebuilds sem boilerplate extra.

---

## Referências

- [Representando estados da UI com sealed classes no Dart](./ui-state-sealed-classes.md)
- [Documentação oficial do Riverpod](https://riverpod.dev)
- [Documentação oficial do Provider](https://pub.dev/packages/provider)
- [Sealed classes no Dart](https://dart.dev/language/class-modifiers#sealed)
- [Dart patterns e pattern matching](https://dart.dev/language/patterns)
