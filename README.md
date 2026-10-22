# Guia Turístico — Aplicativo Flutter

Aplicativo móvel desenvolvido em **Flutter** para cadastro, listagem e gerenciamento de pontos turísticos, consumindo uma API REST com gerenciamento de estado reativo via **Provider**, integração com recursos nativos do dispositivo (câmera e galeria) e persistência de sessão.

Projeto prático desenvolvido na disciplina de **Desenvolvimento para Dispositivos Móveis II** (Fatec).

---

## Funcionalidades

- **Listagem de Lugares**: Exibição dinâmica de pontos turísticos cadastrados com tratamento de estados de carregamento (`CircularProgressIndicator`), lista vazia e erros da API.
- **Cadastro de Pontos Turísticos**: Formulário completo para inclusão de novos locais com nome, descrição, categoria, latitude e longitude.
- **Captura e Seleção de Imagens**: Acesso à câmera e à galeria do dispositivo através do `image_picker`, com pré-visualização em tempo real e menu suspenso (`showModalBottomSheet`).
- **Gerenciamento de Estado Reativo**: Arquitetura desacoplada utilizando `ChangeNotifier` e `Provider` (`MultiProvider`, `Consumer`), separando a interface da lógica de negócios.
- **Autenticação e Sessão**: Estrutura de login e persistência local de token JWT com `shared_preferences`.
- **Suporte a Temas**: Controlador de tema (`ThemeController`) pronto para alternar entre modo claro e escuro.

---

## Tecnologias e Pacotes Utilizados

- [Flutter](https://flutter.dev/) (Dart SDK `^3.5.0`)
- [provider](https://pub.dev/packages/provider): Gerenciamento de estado reativo e injeção de dependências
- [http](https://pub.dev/packages/http): Consumo de endpoints REST da API
- [image_picker](https://pub.dev/packages/image_picker): Seleção de fotos da galeria e captura pela câmera
- [shared_preferences](https://pub.dev/packages/shared_preferences): Armazenamento local de chave-valor (token de sessão)
- [cupertino_icons](https://pub.dev/packages/cupertino_icons): Ícones visuais

---

## Estrutura de Pastas do Projeto

O projeto adota o padrão arquitetural em camadas (Model-View-Controller / Service):

```text
lib/
├── controllers/              # Gerenciadores de estado (ChangeNotifier)
│   ├── auth_controller.dart    # Estado de autenticação e login
│   ├── camera_controller.dart  # Estado de captura/seleção de imagem
│   ├── lugares_controller.dart # Estado e regras de negócio de pontos turísticos
│   └── theme_controller.dart   # Alternância entre tema claro e escuro
│
├── models/                   # Modelos de dados e serialização JSON
│   └── lugares_model.dart      # Entidade LugaresModel (fromJson / toJson)
│
├── screens/                  # Telas e interfaces de usuário (Views)
│   ├── cadastro_lugar.dart     # Tela de formulário e foto do lugar
│   └── lugares_screen.dart     # Tela de listagem de pontos turísticos
│
├── services/                 # Comunicação externa e APIs
│   ├── auth_service.dart       # Requisições de autenticação na API
│   ├── camera_service.dart     # Encapsulamento do ImagePicker
│   ├── lugares_services.dart   # Requisições HTTP para o endpoint de lugares
│   └── session_service.dart    # Leitura e gravação de token com SharedPreferences
│
└── main.dart                 # Ponto de entrada, configuração de rotas e MultiProvider