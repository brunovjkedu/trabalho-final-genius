/*
 * Testbench dos principais casos pedidos no enunciado.
 *
 * Os tempos do timer sao reduzidos para a simulacao rodar rapido.
 * Aqui os pulsos dos botoes sao aplicados diretamente, sem passar pelo
 * debouncer, porque o objetivo e testar a logica do jogo.
 */
module tb_genius_all_cases;
    reg clk;
    reg rst;
    reg start;
    reg [3:0] key_pulses;

    wire lfsr_enable;
    wire mem_write;
    wire clear_level;
    wire inc_level;
    wire clear_show_count;
    wire inc_show_count;
    wire clear_input_count;
    wire inc_input_count;
    wire timer_clear;
    wire timer_enable;
    wire [1:0] timer_mode;
    wire update_record;
    wire show_led_enable;
    wire use_input_address;
    wire [3:0] state_display_value;
    wire [5:0] level;
    wire [4:0] show_count;
    wire [4:0] input_count;
    wire [1:0] played_symbol;
    wire has_button;
    wire compare_ok;
    wire timer_done;
    wire show_finished;
    wire input_finished;
    wire [3:0] leds;
    wire [6:0] hex0;
    wire [6:0] hex1;
    wire [6:0] hex2;
    wire [6:0] hex3;
    wire [2:0] state;

    integer errors;
    integer i;
    integer round_number;

    parameter IDLE = 3'd0;
    parameter ADD_SYMBOL = 3'd1;
    parameter SHOW_ON = 3'd2;
    parameter SHOW_OFF = 3'd3;
    parameter INPUT_WAIT = 3'd4;
    parameter WIN = 3'd5;
    parameter LOSE = 3'd6;

    genius_control control (
        .clk(clk),
        .rst(rst),
        .start(start),
        .has_button(has_button),
        .compare_ok(compare_ok),
        .timer_done(timer_done),
        .show_finished(show_finished),
        .input_finished(input_finished),
        .level(level),
        .max_level(6'd32),
        .lfsr_enable(lfsr_enable),
        .mem_write(mem_write),
        .clear_level(clear_level),
        .inc_level(inc_level),
        .clear_show_count(clear_show_count),
        .inc_show_count(inc_show_count),
        .clear_input_count(clear_input_count),
        .inc_input_count(inc_input_count),
        .timer_clear(timer_clear),
        .timer_enable(timer_enable),
        .timer_mode(timer_mode),
        .update_record(update_record),
        .show_led_enable(show_led_enable),
        .use_input_address(use_input_address),
        .state_display_value(state_display_value),
        .state(state)
    );

    genius_datapath #(
        .SHOW_TICKS(3),
        .GAP_TICKS(2),
        .ONE_SECOND_TICKS(3),
        .EASY_SECONDS(6'd60),
        .NORMAL_SECONDS(6'd45),
        .HARD_SECONDS(6'd30),
        .VERY_HARD_SECONDS(6'd15)
    ) datapath (
        .clk(clk),
        .rst(rst),
        .key_pulses(key_pulses),
        .lfsr_enable(lfsr_enable),
        .mem_write(mem_write),
        .clear_level(clear_level),
        .inc_level(inc_level),
        .clear_show_count(clear_show_count),
        .inc_show_count(inc_show_count),
        .clear_input_count(clear_input_count),
        .inc_input_count(inc_input_count),
        .timer_clear(timer_clear),
        .timer_enable(timer_enable),
        .timer_mode(timer_mode),
        .difficulty(2'b00),
        .update_record(update_record),
        .show_led_enable(show_led_enable),
        .use_input_address(use_input_address),
        .state_display_value(state_display_value),
        .level(level),
        .show_count(show_count),
        .input_count(input_count),
        .played_symbol(played_symbol),
        .has_button(has_button),
        .compare_ok(compare_ok),
        .timer_done(timer_done),
        .show_finished(show_finished),
        .input_finished(input_finished),
        .leds(leds),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3)
    );

    initial begin
        clk = 1'b0;
        /* Clock apenas para simulacao. Este delay nao vai para a FPGA. */
        forever #5 clk = ~clk;
    end

    task reset_game;
        begin
            /* Coloca o circuito em um estado conhecido antes de cada caso. */
            rst = 1'b1;
            start = 1'b0;
            key_pulses = 4'b0000;
            repeat (3) @(posedge clk);
            rst = 1'b0;
            repeat (2) @(posedge clk);
        end
    endtask

    task press_symbol;
        input [1:0] symbol;
        begin
            /* Gera um pulso de um ciclo no botao correspondente ao simbolo. */
            @(negedge clk);
            key_pulses = 4'b0001 << symbol;
            @(negedge clk);
            key_pulses = 4'b0000;
            repeat (2) @(posedge clk);
        end
    endtask

    task wait_input_state;
        begin
            /* Espera a FSM terminar a exibicao e liberar a entrada. */
            while (state != INPUT_WAIT) begin
                @(posedge clk);
            end
            @(posedge clk);
        end
    endtask

    task play_current_round;
        begin
            wait_input_state;
            /* Reproduz a sequencia correta lendo a memoria interna do datapath. */
            for (i = 0; i < level; i = i + 1) begin
                press_symbol(datapath.memory.memory[i]);
            end
        end
    endtask

    task check_state;
        input [2:0] expected;
        input [120:0] message;
        begin
            if (state != expected) begin
                errors = errors + 1;
                $display("ERRO: %s", message);
            end else begin
                $display("OK: %s", message);
            end
        end
    endtask

    initial begin
        errors = 0;

        /* Caso 1 do enunciado. */
        $display("Caso 1: jogador completa tres rodadas consecutivas");
        reset_game;
        start = 1'b1;
        play_current_round;
        play_current_round;
        play_current_round;
        repeat (3) @(posedge clk);
        if (state == LOSE) begin
            errors = errors + 1;
            $display("ERRO: jogador perdeu durante as tres rodadas corretas");
        end else if (level < 6'd4) begin
            errors = errors + 1;
            $display("ERRO: nivel nao avancou apos tres rodadas");
        end else begin
            $display("OK: tres rodadas corretas foram aceitas");
        end

        /* Caso 2 do enunciado. */
        $display("Caso 2: jogador vence a partida");
        reset_game;
        start = 1'b1;
        for (round_number = 1; round_number <= 32; round_number = round_number + 1) begin
            play_current_round;
        end
        repeat (3) @(posedge clk);
        check_state(WIN, "estado final deve ser WIN");

        /* Caso 3 do enunciado. */
        $display("Caso 3: reset durante a execucao");
        reset_game;
        start = 1'b1;
        while (state != SHOW_ON) begin
            @(posedge clk);
        end
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);
        check_state(IDLE, "reset deve retornar para IDLE");

        /* Caso 4 do enunciado. */
        $display("Caso 4: timeout da entrada do jogador");
        reset_game;
        start = 1'b1;
        wait_input_state;
        while (state != LOSE) begin
            @(posedge clk);
        end
        check_state(LOSE, "timeout deve levar para LOSE");

        if (errors == 0) begin
            $display("Todos os casos passaram.");
        end else begin
            $display("Total de erros: %0d", errors);
        end

        $finish;
    end
endmodule
