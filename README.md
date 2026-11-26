# Guia Explorer — Aplicativo Flutter de Guia Turístico

Aplicativo móvel desenvolvido em **Flutter** para exploração, listagem, favoritação e cadastro de pontos turísticos. O projeto integra consumo de API REST, autenticação com **Google (Firebase Authentication)** e persistência de sessão, gerenciamento de estado reativo com **Provider**, recursos nativos de hardware (câmera, galeria e GPS em tempo real), visualização interativa em mapas com **OpenStreetMap**, geocodificação de endereços/CEP via **Nominatim API**, abertura de rotas externas e compartilhamento nativo.

Projeto prático desenvolvido na disciplina de **Desenvolvimento para Dispositivos Móveis II** (Fatec).

---

## Funcionalidades

- **Autenticação com Google e Persistência de Sessão**:
  - Login integrado com conta Google via **Firebase Authentication** (`firebase_auth` e `google_sign_in`), exibindo foto, nome e e-mail do usuário.
  - Autenticação na API REST (`https://guia.liliaborges.com.br/login`) com armazenamento local de token JWT via `shared_preferences`.
  - Persistência automática de sessão através do `AuthGate` (mantém o usuário conectado ao reabrir o app) e opção de **Logout** completa.

- **Mapa Interativo de Pontos Turísticos (OpenStreetMap)**:
  - Exibição em mapa via `flutter_map` (OpenStreetMap).
  - Marcadores (*pins*) personalizados exibindo as **fotos dos estabelecimentos** cadastrados (com destaque visual para favoritos).
  - Toque interativo nos marcadores com abertura de modal (*BottomSheet*) contendo foto em destaque, nome, categoria, descrição, distância estimada e ações rápidas.
  - Marcador de localização atual do usuário via sensor GPS, botão de centralização rápida e contador dinâmico de locais cadastrados.

- **Geolocalização, Distância e Busca por Endereço/CEP (Nominatim API)**:
  - Cálculo automático da distância em tempo real (`Geolocator.distanceBetween`, exibida em metros ou quilômetros) entre o usuário e cada estabelecimento, tanto no mapa quanto na listagem.
  - Integração com a API do Nominatim/OpenStreetMap para conversão automática de endereços ou CEP em latitude e longitude no formulário.
  - Botão "Usar minha localização atual (GPS)" e mini mapa embutido para pré-visualização do ponto.

- **Sistema de Favoritos**:
  - Marcação e remoção de estabelecimentos favoritos tanto na lista quanto nos detalhes do mapa.
  - Persistência local dos favoritos com `shared_preferences`.
  - Filtro rápido na barra superior da listagem para visualizar apenas **Meus Favoritos**.

- **Rotas e Compartilhamento Nativo**:
  - **Como Chegar**: abertura direta de rotas para o ponto turístico no **Google Maps** ou **Waze** via `url_launcher`.
  - **Compartilhar**: compartilhamento nativo de estabelecimentos (nome, categoria, descrição, distância e link do mapa) via WhatsApp, E-mail e demais aplicativos instalados usando `share_plus`.

- **Captura e Seleção de Fotos**:
  - Captura pela câmera fotográfica ou seleção na galeria usando `image_picker`, exibindo a imagem nos pins do mapa e nos cards.

- **Arquitetura e Identidade Visual**:
  - Separação em camadas (Model-View-Controller / Service) com `ChangeNotifier` e `Provider`.
  - Tema Material 3 customizado com paleta Verde Petróleo (*Teal* `#00695C`) e detalhes em Âmbar (`#FFA000`).

---

## Tecnologias e Pacotes Utilizados

- [Flutter](https://flutter.dev/) (Dart SDK `^3.5.0`)
- [provider](https://pub.dev/packages/provider): Gerenciamento de estado reativo e injeção de dependências
- `firebase_core` e `firebase_auth`: Integração com Firebase e autenticação de usuários
- [google_sign_in](https://pub.dev/packages/google_sign_in): Login com conta Google
- [flutter_map](https://pub.dev/packages/flutter_map): Renderização de mapas OpenStreetMap
- [latlong2](https://pub.dev/packages/latlong2): Manipulação de coordenadas geográficas
- [geolocator](https://pub.dev/packages/geolocator): Acesso ao GPS e cálculo de distâncias
- [url_launcher](https://pub.dev/packages/url_launcher): Abertura de rotas no Google Maps e Waze
- [share_plus](https://pub.dev/packages/share_plus): Compartilhamento nativo de estabelecimentos
- [http](https://pub.dev/packages/http): Consumo da API REST e da API Nominatim
- [image_picker](https://pub.dev/packages/image_picker): Captura pela câmera e seleção da galeria
- [shared_preferences](https://pub.dev/packages/shared_preferences): Persistência local de sessão, favoritos e fotos
- [cupertino_icons](https://pub.dev/packages/cupertino_icons): Pacote de ícones

---

## Estrutura de Pastas do Projeto

```text
lib/
├── controllers/
│   ├── auth_controller.dart        # Sessão, login Google/API e logout
│   ├── camera_controller.dart      # Gerenciamento de captura e seleção de imagem
│   ├── gps_controller.dart         # Coordenadas GPS do usuário e cálculo de distância
│   ├── lugares_controller.dart     # Lugares da API, sistema de favoritos e fotos locais
│   └── theme_controller.dart       # Alternância de temas
│
├── models/
│   └── lugares_model.dart          # Modelo LugaresModel (fromJson / toJson com suporte a imagem)
│
├── screens/
│   ├── login_screen.dart           # Tela de conta, login Google (Firebase), login API e logout
│   ├── mapa_lugares_screen.dart    # Mapa interativo com fotos nos pins, distância, rotas e compartilhamento
│   ├── lugares_screen.dart         # Listagem de lugares com filtro de favoritos, distância e ações
│   └── cadastro_lugar.dart         # Formulário com foto, Nominatim (CEP/endereço), GPS e mini-mapa
│
├── services/
│   ├── acoes_lugar_service.dart    # Abertura de rotas (Google Maps/Waze) e compartilhamento nativo
│   ├── auth_service.dart           # Autenticação na API REST e via Firebase/Google Sign-In
│   ├── camera_service.dart         # Encapsulamento do ImagePicker
│   ├── geocoding_service.dart      # Busca de lat/lon por endereço/CEP (Nominatim API)
│   ├── gps_service.dart            # Verificação de permissões e obtenção de sinal GPS
│   ├── lugares_service.dart        # Endpoints GET e POST de lugares na API REST
│   └── session_service.dart        # Persistência local de token, favoritos e fotos (SharedPreferences)
│
├── firebase_options.dart           # Configurações geradas pelo FlutterFire CLI
└── main.dart                       # Inicialização do Firebase, MultiProvider, AuthGate e rotas