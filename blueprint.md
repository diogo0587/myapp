# Visão Geral

Este aplicativo para Android foi projetado para capturar e armazenar as notificações recebidas no dispositivo do usuário. Ele oferece uma maneira conveniente de visualizar, gerenciar e interagir com as notificações, mesmo que tenham sido dispensadas da barra de status.

## Recursos Implementados

*   **Captura de Notificações em Tempo Real:** Um serviço em segundo plano escuta e captura novas notificações assim que chegam.
*   **Interface de Usuário Intuitiva:** Uma interface limpa e amigável para visualizar as notificações salvas.
*   **Visualização Detalhada:** Capacidade de tocar em uma notificação para ver seu conteúdo completo, incluindo texto, ícones e ações.
*   **Persistência de Dados:** As notificações são salvas no armazenamento local, garantindo que não sejam perdidas ao reiniciar o aplicativo.
*   **Gerenciamento de Notificações:** Funcionalidades para excluir notificações individuais ou limpar todo o histórico.
*   **Busca e Filtragem:** Opções para buscar notificações por aplicativo, palavra-chave ou período.

## Estilo e Design

*   **Tema Material You:** O aplicativo seguirá as diretrizes do Material You, com um esquema de cores dinâmico que se adapta ao papel de parede do usuário.
*   **Tipografia Clara e Legível:** Fontes e tamanhos de texto serão escolhidos para garantir a legibilidade.
*   **Ícones e Imagens:** Ícones do Material Design serão usados para ações e elementos de navegação.

---

## Plano de Implementação (Atual)

1.  **Melhoria da Interface (UI):**
    *   Aplicar um `ThemeData` mais moderno com `ColorScheme` para um visual mais agradável.
    *   Utilizar `Card` para cada item da lista de notificações, melhorando a separação visual.
    *   Criar uma tela de detalhes (`NotificationDetailScreen`) para exibir o conteúdo completo de uma notificação.
    *   Adicionar um campo de busca na `AppBar` para filtrar as notificações.

2.  **Lógica de Busca:**
    *   Implementar a lógica de filtragem no `NotificationProvider` para que a lista de notificações seja atualizada de acordo com o termo de busca.
