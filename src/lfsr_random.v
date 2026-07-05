/*
 * Gerador pseudoaleatorio usado para sortear o proximo simbolo.
 * Enquanto o jogo esta parado, ele continua girando para variar a sequencia.
 */
module lfsr_random (
    input clk,
    input reset,
    input habilita,
    input gira_em_espera,
    output [1:0] simbolo_randomico
);
    reg [3:0] lfsr;
    wire realimentacao;

    assign realimentacao = lfsr[3] ^ lfsr[2];
    assign simbolo_randomico = lfsr[1:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            /* Nao pode iniciar em 0000, senao o LFSR fica travado. */
            lfsr <= 4'b1011;
        end else if (habilita || gira_em_espera) begin
            lfsr <= {lfsr[2:0], realimentacao};
        end
    end
endmodule
