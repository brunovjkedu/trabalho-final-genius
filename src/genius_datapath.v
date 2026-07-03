/*
 * Datapath do jogo Genius.
 *
 * Este modulo junta os blocos que armazenam e processam dados: LFSR, memoria,
 * registrador de nivel, contadores, comparador, temporizador, LEDs e displays.
 * Ele nao decide a ordem do jogo; quem decide e a unidade de controle.
 */
module genius_datapath (
    input clk,
    input rst,
    input [3:0] key_pulses,
    input lfsr_enable,
    input mem_write,
    input clear_level,
    input inc_level,
    input clear_show_count,
    input inc_show_count,
    input clear_input_count,
    input inc_input_count,
    input timer_clear,
    input timer_enable,
    input [1:0] timer_mode,
    input show_led_enable,
    input use_input_address,
    input [3:0] state_display_value,
    output [3:0] level,
    output [3:0] show_count,
    output [3:0] input_count,
    output [1:0] played_symbol,
    output has_button,
    output compare_ok,
    output timer_done,
    output show_finished,
    output input_finished,
    output [3:0] leds,
    output [6:0] hex0,
    output [6:0] hex3
);
    parameter SHOW_TICKS = 32'd25000000;
    parameter GAP_TICKS = 32'd10000000;
    parameter INPUT_TICKS = 32'd3000000000;

    wire [1:0] random_symbol;
    wire [1:0] expected_symbol;
    wire [3:0] read_address;
    wire [3:0] write_address;

    /* A mesma memoria e lida pela exibicao ou pela comparacao da entrada. */
    assign read_address = use_input_address ? input_count : show_count;

    /* O novo simbolo e gravado na ultima posicao do nivel atual. */
    assign write_address = (level == 4'd0) ? 4'd0 : (level - 4'd1);

    /* Indicam para a FSM quando a exibicao/entrada chegou no fim da rodada. */
    assign show_finished = (show_count == (level - 4'd1));
    assign input_finished = (input_count == (level - 4'd1));

    /* 7.1 - Gerador Pseudoaleatorio. */
    lfsr_random random_generator (
        .clk(clk),
        .rst(rst),
        .enable(lfsr_enable),
        .simbolo_randomico(random_symbol)
    );

    /* 7.2 - Memoria da Sequencia. */
    sequence_memory memory (
        .clk(clk),
        .write_enable(mem_write),
        .write_address(write_address),
        .write_data(random_symbol),
        .read_address(read_address),
        .read_data(expected_symbol)
    );

    /* 7.3 - Registrador de Nivel. */
    level_register level_reg (
        .clk(clk),
        .rst(rst),
        .clear(clear_level),
        .increment(inc_level),
        .level(level)
    );

    /* 7.4 - Contador de Exibicao. */
    counter4 show_counter (
        .clk(clk),
        .rst(rst),
        .clear(clear_show_count),
        .increment(inc_show_count),
        .count(show_count)
    );

    /* 7.5 - Contador de Entrada. */
    counter4 input_counter (
        .clk(clk),
        .rst(rst),
        .clear(clear_input_count),
        .increment(inc_input_count),
        .count(input_count)
    );

    /* Transforma pulsos dos botoes em simbolo jogado. */
    button_decoder decoder (
        .pulses(key_pulses),
        .has_button(has_button),
        .symbol(played_symbol)
    );

    /* 7.6 - Comparador de Sequencia. */
    sequence_compare comparator (
        .simbolo_esperado(expected_symbol),
        .simbolo_jogado(played_symbol),
        .resultado_comparacao(compare_ok)
    );

    /* 7.7 - Temporizador. */
    timer #(
        .SHOW_TICKS(SHOW_TICKS),
        .GAP_TICKS(GAP_TICKS),
        .INPUT_TICKS(INPUT_TICKS)
    ) game_timer (
        .clk(clk),
        .rst(rst),
        .clear(timer_clear),
        .enable(timer_enable),
        .mode(timer_mode),
        .done(timer_done)
    );

    /* Liga o LED correspondente ao simbolo esperado. */
    led_driver leds_out (
        .enable(show_led_enable),
        .symbol(expected_symbol),
        .leds(leds)
    );

    /* 7.8 - Decodificador para Display de Sete Segmentos. */
    seven_segment level_display (
        .value(level),
        .segments(hex0)
    );

    /* 7.8 - Decodificador para Display de Sete Segmentos. */
    seven_segment state_display (
        .value(state_display_value),
        .segments(hex3)
    );
endmodule
