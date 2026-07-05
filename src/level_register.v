/*
 * 7.3 - Registrador de Nivel.
 *
 * O nivel representa o tamanho da sequencia que o jogador precisa repetir.
 * O jogo comeca no nivel 1 e pode chegar ate o nivel 32.
 *
 * O clk e necessario porque nivel e um registrador.
 * O valor do nivel precisa ficar armazenado e so deve mudar na borda do clock,
 * quando a FSM manda limpar ou incrementar.
 */
module level_register (
    input clk,
    input reset,
    input limpar,
    input incrementar,
    output reg [5:0] nivel
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            nivel <= 6'd0;
        end else if (limpar) begin
            /* Ao iniciar/voltar ao ESPERANDO, deixamos preparado o nivel 1. */
            nivel <= 6'd1;
        end else if (incrementar && nivel < 6'd32) begin
            nivel <= nivel + 6'd1;
        end
    end
endmodule
