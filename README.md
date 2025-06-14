# Banco de Registradores e Memória

Nas últimas atividades, desenvolvemos uma unidade capaz de realizar operações aritméticas (ALU) e uma unidade de controle responsável por coordenar seu funcionamento. No entanto, talvez você esteja se perguntando: **de onde vêm e para onde vão os valores processados pela nossa ALU?**

Como você pode imaginar, esses dados vêm da memória e do banco de registradores — uma pequena memória interna ao processador, com acesso extremamente rápido (quando nos referimos a "acesso instantâneo", queremos dizer leitura e escrita realizadas em no máximo um ciclo de clock).

Nesta atividade, vamos implementar dois módulos essenciais para o funcionamento de qualquer processador: um **Banco de Registradores** (*Register Bank* ou *Register File*) e uma **Memória**.

---

## Banco de Registradores

O padrão RISC-V define um banco com **32 registradores de propósito geral**, cada um com 32 bits de largura no modo RV32 (ou 64 bits no modo RV64). Quando extensões de ponto flutuante estão presentes, são adicionados mais 32 registradores específicos, mas **nesta atividade focaremos apenas no banco de registradores convencional**, sem suporte a ponto flutuante. Um detalhe importante a se comentar e que em RISC-V o registrador 0 ou x0, sempre possui o valor 0, então ao realizar escritas neste registrador a mesma deve ser ignorada e o valor de x0 deve continuar sendo 0.

O banco de registradores deve ser capaz de:

* **Ler dois registradores por vez** (`RS1` e `RS2`)
* **Escrever em um registrador por vez** (`RD`)

### Entradas

* `RS1_ADDR_i`, `RS2_ADDR_i`, `RD_ADDR_i`: endereços dos registradores (5 bits cada)
* `data_i`: valor a ser escrito no registrador `RD`
* `wr_en_i`: habilita a escrita
* `clk`: clock do sistema

### Saídas

* `RS1_data_o`, `RS2_data_o`: dados lidos dos registradores `RS1` e `RS2`

> **Importante:**
>
> * **Leitura** é **assíncrona**, ou seja, a saída reflete imediatamente qualquer mudança no endereço.
> * **Escrita** é **síncrona**, ocorrendo apenas na borda de subida do clock quando `wr_en_i` estiver ativo.

---

## Memória

A memória nesta atividade simula um bloco de SDRAM. Conceitualmente, ela funciona como **um grande banco de registradores**, mas com acesso a apenas **um endereço por vez** (ou leitura, ou escrita, mas não ambos simultaneamente).

### Entradas

* `clk`: clock do sistema
* `rd_en_i`: habilita a leitura
* `wr_en_i`: habilita a escrita
* `addr_i`: endereço da posição de memória (32 bits)
* `data_i`: dado a ser escrito

### Saídas

* `data_o`: dado lido
* `ack_o`: sinal de confirmação da operação (leitura ou escrita)

A memória será inicializada a partir de um arquivo (`MEMORY_FILE`) e terá um tamanho fixo definido por `MEMORY_SIZE`, ambos passados como parâmetros ao módulo. Cada posição de memória armazena **32 bits**, mas os endereços são fornecidos em **bytes**, então é necessário alinhar os acessos de 4 em 4 bytes (ignorando os 2 bits menos significativos do endereço).

#### Exemplo de Acesso (Pseudocódigo)

```txt
se rd_en_i == 1:
    data_o = memory[addr_i[31:2]]
senão:
    data_o = 0

se wr_en_i == 1:
    memory[addr_i[31:2]] = data_i
```

---

## Atividade

Implemente os módulos `Registers` e `Memory` em **Verilog**, seguindo os templates abaixo:

### Banco de Registradores

```verilog
module Registers (
    input  wire clk,
    input  wire wr_en_i,
    
    input  wire [4:0] RS1_ADDR_i,
    input  wire [4:0] RS2_ADDR_i,
    input  wire [4:0] RD_ADDR_i,

    input  wire [31:0] data_i,
    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);
    // Implemente aqui
endmodule
```

### Memória

```verilog
module Memory #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire        clk,

    input  wire        rd_en_i,
    input  wire        wr_en_i,

    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o,

    output wire        ack_o
);
    // Implemente aqui
endmodule
```

> Dica: ao iniciar a simulação, tanto os registradores quanto a memória estão populados com valores desconhecidos. Esse tipo de dado é representado como `xxxx` ou não inicializado. Somente após uma escrita que os campos passarão a ter dados válidos. 

---

## Execução da Atividade

Utilize os templates fornecidos e execute os testes com o script `./run-all.sh`. O resultado será exibido como `OK` em caso de sucesso ou `ERRO` se houver alguma falha.

Se necessário, crie casos de teste adicionais para validar sua implementação.

---

## Entrega

Realize o *commit* no repositório do **GitHub Classroom**. O sistema de correção automática irá executar os testes e atribuir uma nota com base nos resultados.

> **Dica:**
> Não modifique os arquivos de correção. Para entender melhor o funcionamento dos testes, consulte o script `run.sh` disponível no repositório.
