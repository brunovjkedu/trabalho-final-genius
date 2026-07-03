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
    input [1:0] difficulty,
    input update_record,
    input show_led_enable,
    input use_input_address,
    input [3:0] state_display_value,
    output [5:0] level,
    output [4:0] show_count,
    output [4:0] input_count,
    output [1:0] played_symbol,
    output has_button,
    output compare_ok,
    output timer_done,
    output show_finished,
    output input_finished,
    output [3:0] leds,
    output [7:0] green_leds,
    output [6:0] hex0,
    output [6:0] hex1,
    output [6:0] hex2,
    output [6:0] hex3
);
    parameter SHOW_TICKS = 32'd25000000;
    parameter GAP_TICKS = 32'd10000000;
    parameter ONE_SECOND_TICKS = 32'd50000000;
    parameter EASY_SECONDS = 6'd60;
    parameter NORMAL_SECONDS = 6'd45;
    parameter HARD_SECONDS = 6'd30;
    parameter VERY_HARD_SECONDS = 6'd15;

    wire [1:0] random_symbol;
    wire [1:0] expected_symbol;
    wire [4:0] read_address;
    wire [4:0] write_address;
    wire [3:0] game_leds;
    wire [5:0] seconds_left;
    wire [5:0] record;
    wire [5:0] display_number;
    wire [3:0] display_tens;
    wire [3:0] display_ones;
    wire [3:0] level_digit;
    wire show_record;
    wire show_seconds;
    wire [6:0] normal_hex0;
    wire [6:0] normal_hex1;
    wire [6:0] normal_hex2;

    /* A mesma memoria e lida pela exibicao ou pela comparacao da entrada. */
    assign read_address = use_input_address ? input_count : show_count;

    /* O novo simbolo e gravado na ultima posicao do nivel atual. */
    assign write_address = (level == 6'd0) ? 5'd0 : (level[4:0] - 5'd1);

    /* Indicam para a FSM quando a exibicao/entrada chegou no fim da rodada. */
    assign show_finished = (show_count == (level[4:0] - 5'd1));
    assign input_finished = (input_count == (level[4:0] - 5'd1));

    /*
     * Durante a entrada, HEX2/HEX1 mostram o tempo restante.
     * Em IDLE, WIN e LOSE, mostram o recorde armazenado.
     * Durante exibicao e pausa, ficam apagados para nao confundir o jogador.
     */
    assign show_seconds = (state_display_value == 4'd2);
    assign show_record = (state_display_value == 4'd0 ||
                          state_display_value == 4'd3 ||
                          state_display_value == 4'd4);
    assign display_number = show_seconds ? seconds_left :
                            show_record ? record :
                            6'd0;
    assign level_digit = (level >= 6'd30) ? (level - 6'd30) :
                         (level >= 6'd20) ? (level - 6'd20) :
                         (level >= 6'd10) ? (level - 6'd10) :
                         level[3:0];

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
        .ONE_SECOND_TICKS(ONE_SECOND_TICKS),
        .EASY_SECONDS(EASY_SECONDS),
        .NORMAL_SECONDS(NORMAL_SECONDS),
        .HARD_SECONDS(HARD_SECONDS),
        .VERY_HARD_SECONDS(VERY_HARD_SECONDS)
    ) game_timer (
        .clk(clk),
        .rst(rst),
        .clear(timer_clear),
        .enable(timer_enable),
        .mode(timer_mode),
        .difficulty(difficulty),
        .done(timer_done),
        .seconds_left(seconds_left)
    );

    record_register record_reg (
        .clk(clk),
        .rst(rst),
        .update(update_record),
        .level(level),
        .record(record)
    );

    decimal_digits two_digits (
        .value(display_number),
        .tens(display_tens),
        .ones(display_ones)
    );

    /* Liga o LED correspondente ao simbolo esperado. */
    led_driver leds_out (
        .enable(show_led_enable),
        .symbol(expected_symbol),
        .leds(game_leds)
    );

    /* 7.8 - Decodificador para Display de Sete Segmentos. */
    seven_segment level_display (
        .value(level_digit),
        .segments(normal_hex0)
    );

    seven_segment display_ones_out (
        .value(display_ones),
        .segments(normal_hex1)
    );

    seven_segment display_tens_out (
        .value(display_tens),
        .segments(normal_hex2)
    );

    animation_driver animations (
        .clk(clk),
        .rst(rst),
        .state_display_value(state_display_value),
        .game_leds(game_leds),
        .normal_hex0(normal_hex0),
        .normal_hex1((show_seconds || show_record) ? normal_hex1 : 7'b1111111),
        .normal_hex2((show_seconds || show_record) ? normal_hex2 : 7'b1111111),
        .leds(leds),
        .green_leds(green_leds),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2)
    );

    /* 7.8 - Decodificador para Display de Sete Segmentos. */
    seven_segment state_display (
        .value(state_display_value),
        .segments(hex3)
    );
endmodule
