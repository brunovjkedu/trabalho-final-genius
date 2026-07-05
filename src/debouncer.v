/*
 * Filtra o ruido mecanico dos botoes KEY.
 * A saida pulso fica em 1 por um ciclo quando uma apertada valida e detectada.
 */
module debouncer (
    input clk,
    input reset,
    input entrada_ruidosa,
    output reg pulso
);
    parameter TEMPO_ESTAVEL = 250000; /* 5 ms com clock de 50 MHz. */

    reg estado_estavel;
    reg ultima_amostra;
    reg [18:0] contador;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado_estavel <= 1'b0;
            ultima_amostra <= 1'b0;
            contador <= 19'd0;
            pulso <= 1'b0;
        end else begin
            pulso <= 1'b0;

            if (entrada_ruidosa != ultima_amostra) begin
                ultima_amostra <= entrada_ruidosa;
                contador <= 19'd0;
            end else if (contador < TEMPO_ESTAVEL) begin
                contador <= contador + 19'd1;
            end else if (estado_estavel != ultima_amostra) begin
                /* So aceita o botao depois que ele fica estavel por alguns ciclos. */
                estado_estavel <= ultima_amostra;

                if (ultima_amostra) begin
                    pulso <= 1'b1;
                end
            end
        end
    end
endmodule
