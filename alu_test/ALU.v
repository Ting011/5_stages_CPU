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
    reg[4:0] sa; // constant, 0 ~ 31
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
                    flags[0] <= 1'b0;
                flags[2:1] <= {result == 32'b0, result[31]};
            end
            else if(func == 6'b100001) // addu
            begin // addu
                result <= regA + regB;
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b100010)
            begin // sub(overflow)
                if(rs == 5'b0)
                begin
                    result <= regA + ~regB + 1;
                    if(regA[31] != regB[31])
                    begin
                        flags[0] <= result[31] ^ regA[31];
                    end
                    else
                        flags[0] <= 1'b0;
                end
                else
                begin
                    result <= regB + ~regA + 1;
                    if(regA[31] != regB[31])
                    begin
                        flags[0] <= result[31] ^ regB[31];
                    end
                    else
                        flags[0] <= 1'b0;
                end
                flags[2:1] <= {result == 32'b0, result[31]};
            end
            else if(func == 6'b100011)
            begin // subu
                if(rs == 5'b0)
                begin
                    result <= regA + ~regB + 1;
                end
                else
                begin
                    result <= regB + ~regA + 1;
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b100100)
            begin // and
                result <= regA & regB;
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b100111)
            begin // nor
                result <= ~(regA | regB);
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b100101)
            begin // or
                result <= regA | regB;
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b100110)
            begin // xor
                result <= regA ^ regB;
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b101010)
            begin // slt(signed)
                if(rs == 5'b0)
                begin
                    result <= regA + ~regB + 1;
                    if(regA[31] != regB[31])
                    begin
                        flags[0] <= result[31] ^ regA[31];
                    end
                    else
                        flags[0] <= 1'b0;
                end
                else
                begin
                    result <= regB + ~regA + 1;
                    if(regA[31] != regB[31])
                    begin
                        flags[0] <= result[31] ^ regB[31];
                    end
                    else
                        flags[0] <= 1'b0;
                end
                flags[2:1] <= {result == 32'b0, result[31]};
            end
            else if(func == 6'b101011)
            begin // sltu
                if(rs == 5'b0)
                begin
                    result <= regA + ~regB + 1;
                end
                else
                begin
                    result <= regB + ~regA + 1;
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b000000)
            begin // sll
                if(rt == 5'b0)
                begin
                    result <= regA << sa;
                end
                else
                begin
                    result <= regB << sa;
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b000100)
            begin // sllv
                if(rt == 5'b0)
                begin
                    result <= regA << regB;
                end
                else
                begin
                    result <= regB << regA;
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b000010)
            begin // srl
                if(rt == 5'b0)
                begin
                    result <= regA >> sa;
                end
                else
                begin
                    result <= regB >> sa;
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b000110)
            begin // srlv
                if(rt == 5'b0)
                begin
                    result <= regA >> regB;
                end
                else
                begin
                    result <= regB >> regA;
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b000011)
            begin // sra
                if(rt == 5'b0)
                begin
                    result <= {regA[31], regA >> sa};
                end
                else
                begin
                    result <= {regB[31], regB >> sa};
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
            else if(func == 6'b000111)
            begin // srav
                if(rt == 5'b0)
                begin
                    result <= {regA[31], regA >> regB};
                end
                else
                begin
                    result <= {regB[31], regB >> regA};
                end
                flags <= {result == 32'b0, result[31], 1'b0};
            end
        end
        // I: reg[rt] <- reg[rs] op imm32
        else if(opcode == 6'b001000)
        begin // addi(overflow)
            if(rs == 5'b0)
            begin
                result <= regA + {{16{imm16[15]}}, imm16};
                if(regA[31] == imm16[15])
                begin
                    flags[0] <= regA[31] ^ result[31];
                end
                else
                begin
                    flags[0] <= 1'b0;
                end
            end
            else
            begin
                result <= regB + {{16{imm16[15]}}, imm16};
                if(regB[31] == imm16[15])
                begin
                    flags[0] <= regB[31] ^ result[31];
                end
                else
                begin
                    flags[0] <= 1'b0;
                end
            end
            flags[2:1] <= {result == 32'b0, result[31]};
        end
        else if(opcode == 6'b001001)
        begin // addiu
            if(rs == 5'b0)
            begin
                result <= regA + {16'b0, imm16};
            end
            else
            begin
                result <= regB + {16'b0, imm16};
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b001100)
        begin // andi
            if(rs == 5'b0)
            begin
                result <= regA & {16'b0, imm16};
            end
            else
            begin
                result <= regB & {16'b0, imm16};
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b001101)
        begin // ori
            if(rs == 5'b0)
            begin
                result <= regA | {16'b0, imm16};
            end
            else
            begin
                result <= regB | {16'b0, imm16};
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b001110)
        begin // xori
            if(rs == 5'b0)
            begin
                result <= regA ^ {16'b0, imm16};
            end
            else
            begin
                result <= regB ^ {16'b0, imm16};
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b000100)
        begin // beq
            if(rs == 5'b0)
            begin
                result <= regA + ~regB + 1;
            end
            else
            begin
                result <= regB + ~regA + 1;
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b000101)
        begin // bne
            if(rs == 5'b0)
            begin
                result <= regA + ~regB + 1;
            end
            else
            begin
                result <= regB + ~regA + 1;
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b001010)
        begin // slti(signed)
            if(rs == 5'b0)
            begin
                result <= regA + ~{{16{imm16[15]}}, imm16} + 1;
                if(regA[31] != imm16[15])
                begin
                    flags[0] <= result[31] ^ regA[31];
                end
                else
                    flags[0] <= 1'b0;
            end
            else
            begin
                result <= regB + ~{{16{imm16[15]}}, imm16} + 1;
                if(regB[31] != imm16[15])
                begin
                    flags[0] <= result[31] ^ regB[31];
                end
                else
                    flags[0] <= 1'b0;
            end
            flags[2:1] <= {result == 32'b0, result[31]};
        end
        else if(opcode == 6'b001011)
        begin // sltiu
            if(rs == 5'b0)
            begin
                result <= regA + ~{{16{imm16[15]}}, imm16} + 1;
            end
            else
            begin
                result <= regB + ~{{16{imm16[15]}}, imm16} + 1;
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b100011)
        begin // lw
            if(rs == 5'b0)
            begin
                result <= regA + {16'b0, imm16};
            end
            else
            begin
                result <= regB + {16'b0, imm16};
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else if(opcode == 6'b101011)
        begin // sw
            if(rs == 5'b0)
            begin
                result <= regA + {16'b0, imm16};
            end
            else
            begin
                result <= regB + {16'b0, imm16};
            end
            flags <= {result == 32'b0, result[31], 1'b0};
        end
        else
        begin
            result <= 32'b0;
            flags <= 3'b0;
        end
    end
endmodule
