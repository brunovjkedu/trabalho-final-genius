/*
 * 7.3 - Registrador de Nivel.
 *
 * O nivel representa o tamanho da sequencia que o jogador precisa repetir.
 * O jogo comeca no nivel 1 e pode chegar ate o nivel 32.
 *
 * O clk e necessario porque level e um registrador.
 * O valor do nivel precisa ficar armazenado e so deve mudar na borda do clock,
 * quando a FSM manda limpar ou incrementar.
 */
module level_register (
    input clk,
    input rst,
    input clear,
    input increment,
    output reg [5:0] level
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            level <= 6'd0;
        end else if (clear) begin
            /* Ao iniciar/voltar ao IDLE, deixamos preparado o nivel 1. */
            level <= 6'd1;
        end else if (increment && level < 6'd32) begin
            level <= level + 6'd1;
        end
    end
endmodule
