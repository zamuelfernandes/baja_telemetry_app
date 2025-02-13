# Baja Telemetry Data Monitoring App

## Descrição

Esta aplicação foi desenvolvida para consumir e visualizar dados de telemetria em tempo real a partir de sensores de motor. Ela é **altamente específica** para um formato de dado particular, onde os dados são fornecidos em um formato de texto plano contendo métricas como velocidade, temperatura e RPM. O app é ideal para monitorar o desempenho de motores em tempo real, sendo uma ferramenta valiosa para equipes de engenharia e entusiastas de automobilismo.

---

## Funcionalidades Principais

- **Conexão via IP**: Conecta-se a um servidor local para consumir dados de telemetria.
- **Visualização em Tempo Real**: Exibe os dados em gráficos dinâmicos e animados.
- **Salvamento de Dados**: Armazena os dados localmente e permite exportá-los como um arquivo CSV.
- **Controle de Atualização**: Botão de play/pause para pausar a atualização dos dados.
- **Formato Específico de Dados**: Projetado para consumir dados de formato específico em texto plano.

---

## Como Utilizar

### Pré-requisitos

- **Servidor Local**: Certifique-se de que o servidor que fornece os dados de telemetria está em execução e acessível na rede.
- **IP do Servidor**: O app requer o IP do servidor para se conectar e consumir os dados.

### Passos para Uso

1. **Insira o IP do Servidor**:
 - Na tela inicial, insira o IP do servidor que está fornecendo os dados de telemetria.
 - Clique em "Conectar" para estabelecer a conexão.

2. **Visualize os Dados**:
 - Após a conexão, os dados de velocidade, temperatura e RPM serão exibidos em gráficos animados.
 - Use o botão de play/pause para pausar ou retomar a atualização dos dados.

3. **Salve os Dados**:
 - Clique em "Salvar Dados" para começar a armazenar os dados localmente.
 - Quando terminar, clique em "Baixar Dados" para exportar os dados como um arquivo CSV no diretório de downloads do dispositivo.
 - Use "Cancelar Salvamento" para interromper o salvamento e apagar os dados locais.

4. **Exportação do CSV**:
 - O arquivo CSV será salvo em `/storage/emulated/0/Download/TelemetryData/telemetry_data.csv`.
 - O arquivo contém colunas para `Timestamp`, `Speed (km/h)`, `Temp (°C)` e `RPM`.

---

## Implementação

### Estrutura do Projeto

- **`main.dart`**: Ponto de entrada da aplicação.
- **`screens/`**:
- `home_screen.dart`: Tela inicial para inserir o IP do servidor.
- `data_screen.dart`: Tela de visualização dos dados e gráficos.
- **`providers/`**:
- `telemetry_provider.dart`: Gerencia o estado da aplicação, incluindo a conexão com o servidor e o salvamento dos dados.
- **`components/`**:
- `telemetry_chart.dart`: Componente reutilizável para exibir os gráficos.

### Dependências

- **`http`**: Para fazer requisições HTTP ao servidor.
- **`provider`**: Para gerenciamento de estado.
- **`fl_chart`**: Para renderizar gráficos animados.
- **`device_info_plus`**: Para gerenciar melhor os métodos de acordo com as configurações do dipositivo.
- **`permission_handler`**: Para solicitar permissões de armazenamento.
- **`intl`**: Para formatação de datas e horas.

### Formato de Dados

O app foi projetado para consumir dados no seguinte formato:
```text
# HELP telemetry_speed Velocidade em km/h
# TYPE telemetry_speed gauge
telemetry_speed 97.39
# HELP telemetry_temp Temperatura em Celsius
# TYPE telemetry_temp gauge
telemetry_temp 49.37
# HELP telemetry_rpm Rotacoes por minuto
# TYPE telemetry_rpm gauge
telemetry_rpm 1401
```

---

## Como Executar o Projeto

1. Clone o repositório:
   ```bash
   git clone https://github.com/zamuelfernandes/baja_telemetry_app.git
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o app:
   ```bash
   flutter run
   ```
4. Conecte-se ao servidor e comece a monitorar os dados.

---
## Considerações Finais

Este app foi desenvolvido para um caso de uso específico, onde os dados de telemetria são fornecidos em um formato de texto plano. Ele pode ser adaptado para outros formatos de dados ou funcionalidades conforme necessário.
