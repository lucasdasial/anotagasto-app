# Deploy Manual — Frontend (Flutter Web)

## Pré-requisitos

- Flutter SDK instalado
- Firebase CLI instalado (`npm install -g firebase-tools`)
- Autenticado no Firebase (`firebase login`)

## Passos

```bash
flutter build web --release
firebase deploy --only hosting
```

O build é gerado em `build/web/` e publicado no projeto Firebase `lucasdasial-app-anotagasto`.

## Script

Use o script `docs/deploy.sh` para executar os dois passos de uma vez:

```bash
bash docs/deploy.sh
```
