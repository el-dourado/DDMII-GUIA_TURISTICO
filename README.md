# Guia Explorer — Aplicativo Flutter de Guia Turístico

Aplicativo móvel desenvolvido em **Flutter** para exploração, listagem e cadastro de pontos turísticos. O projeto integra consumo de API REST, gerenciamento de estado reativo com **Provider**, recursos nativos de hardware (câmera, galeria e GPS em tempo real), visualização interativa em mapas com **OpenStreetMap** e geocodificação de endereços/CEP via **Nominatim API**.

Projeto prático desenvolvido na disciplina de **Desenvolvimento para Dispositivos Móveis II** (Fatec).

---

## Funcionalidades

- **Mapa Interativo de Pontos Turísticos**:
  - Exibição em mapa de alta performance via `flutter_map` (OpenStreetMap).
  - Marcadores (*pins*) personalizados com relevo e animação para cada local cadastrado na API.
  - Toque interativo nos marcadores com abertura de modal (*BottomSheet*) contendo nome, categoria, descrição e coordenadas.
  - Marcador de localização atual do usuário com efeito de pulso via sensor GPS.
  - Botão de centralização rápida e contador dinâmico de locais na tela.

- **Geolocalização e Busca Automática de Coordenadas (Nominatim API)**:
  - Integração com a API oficial do Nominatim/OpenStreetMap para conversão automática de endereços ou CEP em latitude e longitude no formulário.
  - Botão "Usar minha localização atual (GPS)" via `geolocator`.
  - Mini mapa interativo embutido no formulário de cadastro com pré-visualização do ponto selecionado.

- **Listagem de Lugares**:
  - Exibição de cards informativos com tratamento de carregamento, lista vazia e erros.
  - Acesso direto para ver o local no mapa ou abrir o formulário.

- **Captura e Seleção de Fotos**:
  - Upload de imagens com suporte a câmera fotográfica e galeria usando `image_picker`.

- **Arquitetura e Estado Reativo**:
  - Separação em camadas (Model-View-Controller / Service).
  - Gerenciamento reativo desacoplado com `ChangeNotifier` e `Provider` (`MultiProvider`, `Consumer`).
  - Persistência de token de sessão com `shared_preferences`.

- **Identidade Visual Personalizada**:
  - Tema Material 3 customizado com paleta Verde Petróleo (*Teal* `#00695C`) e detalhes em Âmbar (`#FFA000`), cantos arredondados e tipografia refinada.

---

## Tecnologias e Pacotes Utilizados

- [Flutter](https://flutter.dev/) (Dart SDK `^3.5.0`)
- [provider](https://pub.dev/packages/provider): Gerenciamento de estado reativo
- [flutter_map](https://pub.dev/packages/flutter_map): Renderização de mapas OpenStreetMap
- [latlong2](https://pub.dev/packages/latlong2): Manipulação e cálculos de coordenadas geográficas
- [geolocator](https://pub.dev/packages/geolocator): Acesso ao hardware de GPS e localização do dispositivo
- [http](https://pub.dev/packages/http): Consumo da API REST e da API Nominatim
- [image_picker](https://pub.dev/packages/image_picker): Captura pela câmera e escolha da galeria
- [shared_preferences](https://pub.dev/packages/shared_preferences): Persistência local de dados e tokens
- [cupertino_icons](https://pub.dev/packages/cupertino_icons): Pacote de ícones

---

## Estrutura de Pastas do Projeto

```text
lib/
├── controllers/
│   ├── auth_controller.dart        # Gerenciamento de login e autenticação
│   ├── camera_controller.dart      # Gerenciamento de captura de imagem
│   ├── gps_controller.dart         # Gerenciamento de coordenadas GPS do usuário
│   ├── lugares_controller.dart     # Regras de negócio e listagem de pontos turísticos
│   └── theme_controller.dart       # Alternância de temas
│
├── models/
│   └── lugares_model.dart          # Modelo de dados LugaresModel (fromJson / toJson)
│
├── screens/
│   ├── mapa_lugares_screen.dart    # Tela principal com mapa interativo e pins
│   ├── lugares_screen.dart         # Listagem de pontos turísticos em cards
│   └── cadastro_lugar.dart         # Formulário com foto, Nominatim e mini-mapa
│
├── services/
│   ├── auth_service.dart           # Requisições de login na API REST
│   ├── camera_service.dart         # Encapsulamento do ImagePicker
│   ├── geocoding_service.dart      # Busca de lat/lon por endereço/CEP (Nominatim API)
│   ├── gps_service.dart            # Verificação de permissões e obtenção de sinal GPS
│   ├── lugares_service.dart        # Endpoints GET e POST de lugares
│   └── session_service.dart        # Leitura e gravação de token com SharedPreferences
│
└── main.dart                       # Ponto de entrada, injeção de dependências e rotas