/*
 * 7.9 - Debouncer.
 *
 * Modulo para filtragem de ruido mecanico das entradas KEY0-KEY3.
 * Ele espera o sinal ficar estavel por TEMPO_ESTAVEL ciclos e gera apenas
 * um pulso quando detecta uma nova pressao valida.
 *
 * Ideia geral:
 * - entrada_ruidosa e o sinal bruto vindo do botao;
 * - quando entrada_ruidosa muda, o modulo nao confia nele imediatamente;
 * - primeiro ele espera o sinal ficar igual por TEMPO_ESTAVEL ciclos;
 * - so depois disso o novo valor e aceito como estado real do botao;
 * - se o novo estado aceito for 1, pulso fica em 1 por um unico ciclo.
 *
 * Isso evita que uma unica apertada seja lida como varias apertadas.
 */
module debouncer (
    input clk,          /* Clock da FPGA. */
    input reset,          /* Reset geral. */
    input entrada_ruidosa,        /* Entrada bruta do botao, ainda com ruido. */
    output reg pulso    /* Pulso limpo de um ciclo quando o botao e apertado. */
);
    /*
     * Numero de ciclos que o sinal precisa ficar sem mudar para ser aceito.
     * Com 50 MHz, 250000 ciclos dao cerca de 5 ms.
     */
    parameter TEMPO_ESTAVEL = 250000;

    reg estado_estavel;   /* Ultimo estado confirmado do botao. */
    reg ultima_amostra;    /* Ultimo valor bruto observado em entrada_ruidosa. */
    reg [18:0] contador;   /* Conta ha quantos ciclos entrada_ruidosa esta igual. */

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            /* Reset limpa o historico do botao. */
            estado_estavel <= 1'b0;
            ultima_amostra <= 1'b0;
            contador <= 19'd0;
            pulso <= 1'b0;
        end else begin
            /*
             * O pulso dura somente um ciclo de clock.
             * Por isso ele volta para zero no inicio de cada ciclo.
             */
            pulso <= 1'b0;

            if (entrada_ruidosa != ultima_amostra) begin
                /*
                 * O sinal bruto mudou.
                 * Pode ser uma apertada real ou apenas ruido mecanico.
                 * Guardamos o novo valor e recomecamos a contagem.
                 */
                ultima_amostra <= entrada_ruidosa;
                contador <= 19'd0;
            end else if (contador < TEMPO_ESTAVEL) begin
                /*
                 * O sinal continua igual ao ultimo valor observado.
                 * Enquanto ainda nao chegou no limite, seguimos contando.
                 */
                contador <= contador + 19'd1;
            end else if (estado_estavel != ultima_amostra) begin
                /*
                 * O sinal ficou estavel tempo suficiente.
                 * Agora aceitamos ultima_amostra como novo estado real do botao.
                 */
                estado_estavel <= ultima_amostra;

                if (ultima_amostra) begin
                    /*
                     * Se o novo estado real e 1, significa uma nova pressao.
                     * Geramos um pulso de um ciclo para o restante do jogo.
                     */
                    pulso <= 1'b1;
                end
            end
        end
    end
endmodule
