`timescale 1ns/1ps

module tb();

    parameter MEMFILE = "teste.txt";

    reg clk;
    reg rst_n;
    reg reg_wr_en, mem_wr_en, mem_rd_en;

    reg  [4:0] RS1_addr, RS2_addr, RD_addr;
    reg  [31:0] mem_addr, mem_data_in;
    wire [31:0] mem_data_out;
    wire [31:0] register_data_1, register_data_2;
    reg  [31:0] reg_write_data;
    wire mem_ack;

    reg [223:0] test_mem [0:512]; // linha com 224 bits
    reg [31:0] expected_reg1, expected_reg2, expected_mem;
    reg test_reg_wr_en, test_mem_wr_en;
    reg done;

    integer fd, i, len, j;
    reg [8*60:1] line;  // buffer para ler linha (mais que 56 p/ \n)
    integer r, pos_line, pos_mem;
    reg [7:0] c;
    reg [3:0] nibble;
    reg [223:0] data_line;

    // Instanciando os módulos
    Registers RegisterBank(
        .clk        (clk),
        .wr_en_i    (reg_wr_en),
        .RS1_ADDR_i (RS1_addr),
        .RS2_ADDR_i (RS2_addr),
        .RD_ADDR_i  (RD_addr),
        .data_i     (reg_write_data),
        .RS1_data_o (register_data_1),
        .RS2_data_o (register_data_2)
    );

    Memory #(
        .MEMORY_FILE (""),
        .MEMORY_SIZE (8192)
    ) MemoryUnit (
        .clk         (clk),
        .rd_en_i     (mem_rd_en),
        .wr_en_i     (mem_wr_en),
        .addr_i      (mem_addr),
        .data_i      (mem_data_in),
        .data_o      (mem_data_out),
        .ack_o       (mem_ack)
    );

    // Clock
    always #5 clk = ~clk;

    // Função para converter um char hex em nibble 4 bits, ou 'x' se inválido
    function [3:0] hexchar_to_nibble;
        input [7:0] ch;
        begin
        if (ch >= "0" && ch <= "9")
            hexchar_to_nibble = ch - "0";
        else if (ch >= "A" && ch <= "F")
            hexchar_to_nibble = ch - "A" + 10;
        else if (ch >= "a" && ch <= "f")
            hexchar_to_nibble = ch - "a" + 10;
        else if (ch == "X" || ch == "x")
            hexchar_to_nibble = 4'bx;
        else
            hexchar_to_nibble = 4'b0; // Ignorar caracteres inválidos (ex: '\n')
        end
    endfunction

    function integer my_strlen;
        input reg [8*60:1] str;
        integer idx;
        begin
            my_strlen = 60;  // valor padrão máximo
            for (idx = 1; idx <= 60; idx = idx + 1) begin
                if (str[idx*8 -: 8] == 8'd0 || str[idx*8 -: 8] == 8'd10) begin // '\0' ou '\n'
                    my_strlen = idx - 1;
                    idx = 61; // forçar saída do loop (condição idx <=60 será falsa)
                end
            end
        end
    endfunction

    reg [31:0] mem_data;

    initial begin
        $dumpfile("saida.vcd");
        $dumpvars(0, tb);

        $display("Iniciando Testbench...");

        clk = 0;
        rst_n = 0;
        reg_wr_en = 0;
        mem_wr_en = 0;
        mem_rd_en = 0;

        #10 rst_n = 1;

        fd = $fopen("teste.txt", "r");
        if (fd == 0) begin
            $display("Erro ao abrir arquivo");
            $finish;
        end

        i = 0;
        j = 0;

        while (!$feof(fd)) begin
            r = $fgets(line, fd);
            if (r == 0) begin
                $display("Erro ao ler linha %0d", i);
                $finish;
            end

            //$display("Linha %0d (raw): %s", i, line);
            data_line = 224'b0;

            for (pos_line = 0; pos_line < 56; pos_line = pos_line + 1) begin
                c = line[(57 - pos_line) * 8 -: 8];
                nibble = hexchar_to_nibble(c);
                data_line[223 - pos_line*4 -: 4] = nibble;
            end

            //$display("Armazenando linha %0d: %h", i, data_line);
            test_mem[i] = data_line;
            i = i + 1;
        end

        $fclose(fd);
        j = i; // Total de linhas lidas
        $display("Total de linhas lidas: %0d", j);

        for (i = 0; i < j; i = i + 1) begin

            // Desempacotamento da linha de teste
            // $display("Desempacotando linha %0d: %h", i, test_mem[i]);
            // Extração dos campos

            test_reg_wr_en = test_mem[i][223:220] == 4'h1;
            test_mem_wr_en = test_mem[i][219:216] == 4'h1;

            RS1_addr       = test_mem[i][215:208];
            RS2_addr       = test_mem[i][207:200];
            RD_addr        = test_mem[i][199:192];
            reg_write_data = test_mem[i][191:160];
            mem_addr       = test_mem[i][159:128];
            mem_data_in    = test_mem[i][127:96];
            expected_reg1  = test_mem[i][95:64];
            expected_reg2  = test_mem[i][63:32];
            expected_mem   = test_mem[i][31:0];

            #10; // Espera o clock estabilizar
            // Leitura da memória se necessário
            mem_rd_en = 1;
            #10;
            mem_rd_en = 0;
        
            wait(mem_ack); // Espera pela confirmação de leitura
            mem_data = mem_data_out;

            if (register_data_1 === expected_reg1)
                $display("=== OK  RS1[%0d] DADO: %h (EXP: %h)", RS1_addr, register_data_1, expected_reg1);
            else
                $display("=== ERRO RS1[%0d] DADO: %h (EXP: %h)", RS1_addr, register_data_1, expected_reg1);

            if (register_data_2 === expected_reg2)
                $display("=== OK  RS2[%0d] DADO: %h (EXP: %h)", RS2_addr, register_data_2, expected_reg2);
            else
                $display("=== ERRO RS2[%0d] DADO: %h (EXP: %h)", RS2_addr, register_data_2, expected_reg2);

            //$display("MEM_ADDR: %h", mem_addr);
            if(mem_data === expected_mem)
                $display("=== OK MEM_DADO: %h (EXP: %h)", mem_data, expected_mem);
            else
                $display("=== ERRO MEM_DADO: %h (EXP: %h) addr: %h", mem_data, expected_mem, mem_addr);

            #10; // Espera o clock estabilizar

            // Aplicar sinais de entrada
            reg_wr_en = test_reg_wr_en;
            mem_wr_en = test_mem_wr_en;
            //$display("Escrita RD_ADDR[%0d] DADO: %h (EXP: %h)", RD_addr, reg_write_data, expected_reg1);

            // Escrita se habilitada
            #10;

            // Desativa escrita após ciclo
            reg_wr_en = 0;
            mem_wr_en = 0;

            #10; // Espaço entre testes
        end

        $display("Testbench finalizado com sucesso.");
        $finish;
    end

    /*always @(posedge clk ) begin
        if(mem_ack)
            mem_data <= mem_data_out; // Captura o dado lido
    end*/

endmodule
