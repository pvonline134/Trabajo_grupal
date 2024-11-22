module BoothMul(
    input clk,                       // Entrada del reloj
    input rst,                       // Señal de reset asíncrono
    input start,                     // Señal para iniciar la multiplicación
    input logic [7:0] X,           // Operando X de 8 bits, permite valores entre -128 y 127
    input logic [7:0] Y,           // Operando Y de 8 bits, permite valores entre -128 y 127
        // Resultado de la multiplicación de 16 bits
    //output reg valid                 // Señal que indica que el resultado es válido
    output logic [15:0] z_out,
    output logic valid_out
);

    reg signed [15:0] next_Z, Z_temp; // Registro para el siguiente resultado y un valor temporal
    reg next_state, pres_state;        // Registro para el estado actual y el siguiente estado
    reg [1:0] temp, next_temp;         // Registro para manejar el estado intermedio del algoritmo de Booth
    reg [2:0] count, next_count;       // Contador de ciclos, actualizado para un multiplicador de 8 bits
    reg next_valid;                    // Registro para la señal de validez del resultado
    reg valid;  
    logic [15:0] Z;


    parameter IDLE = 1'b0;             // Estado IDLE
    parameter START = 1'b1;            // Estado de inicio

    // Bloque siempre que se activa en el flanco positivo del reloj o el flanco negativo del reset
    always @ (posedge clk or posedge rst) begin
        if (rst) begin                  // Si se activa el reset
            Z          <= 16'd0;       // Inicializa Z a 0
            valid      <= 1'b0;        // Inicializa valid a 0 (no válido)
            pres_state <= IDLE;        // Estado presente a IDLE
            temp       <= 2'd0;        // Inicializa temp a 0
            count      <= 3'd0;        // Inicializa el contador a 0
        end else begin
            // Actualiza los registros en el ciclo
            Z          <= next_Z;      // Actualiza Z con el siguiente valor
            valid      <= next_valid;  // Actualiza valid con el siguiente valor
            pres_state <= next_state;  // Actualiza el estado presente con el siguiente estado
            temp       <= next_temp;    // Actualiza temp con el siguiente valor
            count      <= next_count;   // Actualiza count con el siguiente valor
        end
    end

    // Bloque combinacional para determinar el siguiente estado y las salidas
    always @ (*) begin 
        case (pres_state)               // Evaluar el estado presente
            IDLE: begin
                next_count = 3'd0;      // Resetea el contador a 0 en IDLE
                next_valid = 1'b0;      // Establece valid a 0
                if (start) begin        // Si se inicia la multiplicación
                    next_state = START; // Cambia el estado a START
                    next_temp  = {X[0], 1'b0}; // Carga el bit menos significativo de X y un 0
                    next_Z     = {8'd0, X}; // Inicia Z con X en la mitad inferior y ceros en la superior
                end else begin
                    next_state = pres_state; // Mantiene el estado presente
                    next_temp  = 2'd0;        // Resetea temp
                    next_Z     = 16'd0;       // Resetea Z
                end
            end

            START: begin
                // Aplicar el algoritmo de Booth según el valor de temp
                case (temp)
                    2'b10:   Z_temp = {Z[15:8] - Y, Z[7:0]}; // Restar Y del byte superior de Z
                    2'b01:   Z_temp = {Z[15:8] + Y, Z[7:0]}; // Sumar Y al byte superior de Z
                    default: Z_temp = {Z[15:8], Z[7:0]};     // Mantener Z sin cambios
                endcase

                // Actualiza temp para el siguiente par de bits
                next_temp  = {X[count+1], X[count]}; // Obtiene el siguiente par de bits de X
                next_count = count + 1'b1;           // Incrementa el contador
                next_Z     = Z_temp >>> 1;           // Desplazamiento a la derecha de Z_temp
                next_valid = (&count) ? 1'b1 : 1'b0; // Establece valid a 1 si se han procesado tdos los bits
                next_state = (&count) ? IDLE : pres_state; // Cambia al estado IDLE si toos los bits han sido procesados
            end
        endcase
    end

     always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_out <= 0;   // Reinicia el toggle en 0 cuando reset es alto
            z_out <= 16'bz;
        end 
        else if (valid) begin
            valid_out <= 1;   // Activa el toggle cuando enable es alto
            z_out <= Z;
        end
        // Si ni reset ni enable están activos, toggle_out mantiene su valor actual
    end
    

endmodule