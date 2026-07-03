/*
 * Modulo principal para usar na FPGA.
 *
 * Ele conecta os sinais fisicos da placa DE1 aos dois blocos principais do
 * projeto: unidade de controle e datapath. Aqui tambem ficam os debouncers dos
 * botoes KEY, porque eles sao entradas mecanicas da placa.
 */
module genius_top (
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,
    output [3:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3
);
    parameter DEBOUNCE_COUNT = 250000;
    parameter SHOW_TICKS = 32'd25000000;
    parameter GAP_TICKS = 32'd20000000;
    parameter ONE_SECOND_TICKS = 32'd50000000;

    wire rst;
    wire start;
    wire [3:0] key_pressed;
    wire [3:0] key_pulses;
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
    wire [2:0] state;
    wire [5:0] max_level;

    /*
     * SW1 e reset, SW0 inicia a partida.
     * SW8/SW7 escolhem a dificuldade.
     * SW9 escolhe o limite: 0 = 15 niveis, 1 = 32 niveis.
     */
    assign rst = SW[1];
    assign start = SW[0];
    assign max_level = SW[9] ? 6'd32 : 6'd15;

    /* Na DE1 os botoes KEY sao ativos em zero, por isso invertemos. */
    assign key_pressed = ~KEY;

    /* 7.9 - Debouncer: cada botao passa por um filtro antes de chegar ao jogo. */
    debouncer #(.STABLE_COUNT(DEBOUNCE_COUNT)) db0 (.clk(CLOCK_50), .rst(rst), .noisy(key_pressed[0]), .pulse(key_pulses[0]));
    debouncer #(.STABLE_COUNT(DEBOUNCE_COUNT)) db1 (.clk(CLOCK_50), .rst(rst), .noisy(key_pressed[1]), .pulse(key_pulses[1]));
    debouncer #(.STABLE_COUNT(DEBOUNCE_COUNT)) db2 (.clk(CLOCK_50), .rst(rst), .noisy(key_pressed[2]), .pulse(key_pulses[2]));
    debouncer #(.STABLE_COUNT(DEBOUNCE_COUNT)) db3 (.clk(CLOCK_50), .rst(rst), .noisy(key_pressed[3]), .pulse(key_pulses[3]));

    /* A unidade de controle gera os sinais que comandam o datapath. */
    genius_control control (
        .clk(CLOCK_50),
        .rst(rst),
        .start(start),
        .has_button(has_button),
        .compare_ok(compare_ok),
        .timer_done(timer_done),
        .show_finished(show_finished),
        .input_finished(input_finished),
        .level(level),
        .max_level(max_level),
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

    /* O datapath guarda a sequencia, compara jogadas e controla saidas visuais. */
    genius_datapath #(
        .SHOW_TICKS(SHOW_TICKS),
        .GAP_TICKS(GAP_TICKS),
        .ONE_SECOND_TICKS(ONE_SECOND_TICKS)
    ) datapath (
        .clk(CLOCK_50),
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
        .difficulty(SW[8:7]),
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
        .leds(LEDR),
        .hex0(HEX0),
        .hex1(HEX1),
        .hex2(HEX2),
        .hex3(HEX3)
    );
endmodule
