module alu(
        input wire[31:0] instruction,
        input wire[31:0] regA, // the address of regA is 00000, the address of regB is 00001
        input wire[31:0] regB,

        output reg[31:0] result,
        output reg[2:0] flags  // the first bit is zero flag, the second bit is negative flag, the third bit is overflow flag.
    );

    reg[5:0] opcode;
    reg[5:0] func;
    reg[4:0] rs;
    reg[4:0] rt;
    reg[4:0] rd;
    reg[4:0] sa;
    reg[15:0] imm16;

    // R-Type: 000000
    // add, addu, sub, subu, and, nor, or, xor, slt, sltu, sll, sllv, srl, srlv, sra, srav

    // I-Type: except 000000, 00001x, 0100xx
    // addi, addiu, andi, ori, xori, beq, bne, slti, sltiu, lw, sw

    // J-Type: 00001x

    always @(*)
    begin // parse the opcode to check the type of instruction
        opcode <= instruction[31:26];
        func <= instruction[5:0];
        imm16 <= instruction[15:0];
        rs <= instruction[25:21];
        rt <= instruction[20:16];
        rd <= instruction[15:11];
        sa <= instruction[10:6];
    end

    always @(*)
    begin // check the type and fetch values in mem
        if(opcode == 6'b000000) // R: reg[rd] <- reg[rs] op reg[rt]
        begin
            if(func == 6'b100000)
            begin // add(overflow)
                result <= regA + regB;
                if(regA[31] == regB[31])
                begin
                    flags[0] <= result[31] ^ regA[31];
                end
                else
                    flags[0] <= 1'b1;
                flags[2:1] <= {result == 32'b0, result[31]};
            end
            else if(func == 6'b100001) // addu
            begin // addu
                result <= regA + regB;
                flags[0] <= 1'b0;
                flags[2:1] <= {result == 32'b0, result[31]};
            end
            else if(func == 6'b100010) begin // sub(overflow)
                if(rs == 5'b0)begin
                    result <= regA + ~regB + 1;
                end
                else begin
                    result <= regB + ~regA + 1;
                end
                if(regA[31] == regB[31])
                begin
                    flags[0] <= result[31] ^ regA[31];
                end
                else
                    flags[0] <= 1'b1;
                flags[2:1] <= {result == 32'b0, result[31]};
            end
            else if(func == 6'b100011) begin // sub
                if(rs == 5'b0)begin
                    result <= regA + ~regB + 1;
                end
                else begin
                    result <= regB + ~regA + 1;
                end
                flags[0] <= 1'b0;
                flags[2:1] <= {result == 32'b0, result[31]};
            end
        end
        else // I: reg[rt] <- reg[rs] op imm
        begin
            ;
        end
    end
endmodule
