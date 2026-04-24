module control_fsm (
	input clk, reset_n,
	// Status inputs
	input br, brz, addi, subi, sr0, srh0, clr, mov, mova, movr, movrhs, pause,
	input delay_done,
	input temp_is_positive, temp_is_negative, temp_is_zero,
	input register0_is_zero,
	// Control signal outputs
	output reg write_reg_file,
	output reg result_mux_select,
	output reg [1:0] op1_mux_select, op2_mux_select,
	output reg start_delay_counter, enable_delay_counter,
	output reg commit_branch, increment_pc,
	output reg alu_add_sub, alu_set_low, alu_set_high,
	output reg load_temp_register, increment_temp_register, decrement_temp_register,
	output reg [1:0] select_immediate,
	output reg [1:0] select_write_address
);

parameter RESET=5'b00000, FETCH=5'b00001, DECODE=5'b00010,
			BR=5'b00011, BRZ=5'b00100, ADDI=5'b00101, SUBI=5'b00110, SR0=5'b00111,
			SRH0=5'b01000, CLR=5'b01001, MOV=5'b01010, MOVA=5'b01011,
			MOVR=5'b01100, MOVRHS=5'b01101, PAUSE=5'b01110, MOVR_STAGE2=5'b01111,
			MOVR_DELAY=5'b10000, MOVRHS_STAGE2=5'b10001, MOVRHS_DELAY=5'b10010,
			PAUSE_DELAY=5'b10011;

// select_write_address encoding
localparam WA_R0     = 2'b00,
		   WA_FIELD0 = 2'b01,
		   WA_FIELD1 = 2'b10,
		   WA_R2     = 2'b11;

// op1_mux_select encoding
localparam OP1_REG = 2'b00,
		   OP1_PC  = 2'b01,
		   OP1_R2  = 2'b10,
		   OP1_R0  = 2'b11;

// op2_mux_select encoding
localparam OP2_REG = 2'b00,
		   OP2_IMM = 2'b01,
		   OP2_ONE = 2'b10,
		   OP2_TWO = 2'b11;

// select_immediate encoding
localparam IMM_3BIT = 2'b00,
		   IMM_4BIT = 2'b01,
		   IMM_5BIT = 2'b10,
		   IMM_ZERO = 2'b11;

reg [4:0] state;
reg [4:0] next_state_logic;

// Next state logic
always @(*) begin
	next_state_logic = FETCH;

	case (state)
		RESET:  next_state_logic = FETCH;
		FETCH:  next_state_logic = DECODE;

		DECODE: begin
			if      (br)     next_state_logic = BR;
			else if (brz)    next_state_logic = BRZ;
			else if (addi)   next_state_logic = ADDI;
			else if (subi)   next_state_logic = SUBI;
			else if (sr0)    next_state_logic = SR0;
			else if (srh0)   next_state_logic = SRH0;
			else if (clr)    next_state_logic = CLR;
			else if (mov)    next_state_logic = MOV;
			else if (mova)   next_state_logic = MOVA;
			else if (movr)   next_state_logic = MOVR;
			else if (movrhs) next_state_logic = MOVRHS;
			else if (pause)  next_state_logic = PAUSE;
			else             next_state_logic = FETCH;
		end

		// single-cycle instructions
		BR:    next_state_logic = FETCH;
		BRZ:   next_state_logic = FETCH;
		ADDI:  next_state_logic = FETCH;
		SUBI:  next_state_logic = FETCH;
		SR0:   next_state_logic = FETCH;
		SRH0:  next_state_logic = FETCH;
		CLR:   next_state_logic = FETCH;
		MOV:   next_state_logic = FETCH;
		MOVA:  next_state_logic = FETCH;

		// multi-cycle instructions per FSMD
		MOVR:          next_state_logic = MOVR_STAGE2;
		MOVR_STAGE2:   next_state_logic = temp_is_zero ? FETCH : MOVR_DELAY;
		MOVR_DELAY:    next_state_logic = delay_done ? MOVR_STAGE2 : MOVR_DELAY;

		MOVRHS:        next_state_logic = MOVRHS_STAGE2;
		MOVRHS_STAGE2: next_state_logic = temp_is_zero ? FETCH : MOVRHS_DELAY;
		MOVRHS_DELAY:  next_state_logic = delay_done ? MOVRHS_STAGE2 : MOVRHS_DELAY;

		PAUSE:         next_state_logic = PAUSE_DELAY;
		PAUSE_DELAY:   next_state_logic = delay_done ? FETCH : PAUSE_DELAY;

		default:       next_state_logic = FETCH;
	endcase
end

// State register
always @(posedge clk or negedge reset_n) begin
	if (!reset_n)
		state <= RESET;
	else
		state <= next_state_logic;
end

// Output logic
always @(*) begin
	// defaults
	write_reg_file          = 1'b0;
	result_mux_select       = 1'b1; // 1 = ALU output, 0 = constant 0
	op1_mux_select          = OP1_REG;
	op2_mux_select          = OP2_IMM;
	start_delay_counter     = 1'b0;
	enable_delay_counter    = 1'b0;
	commit_branch           = 1'b0;
	increment_pc            = 1'b0;
	alu_add_sub             = 1'b0;
	alu_set_low             = 1'b0;
	alu_set_high            = 1'b0;
	load_temp_register      = 1'b0;
	increment_temp_register = 1'b0;
	decrement_temp_register = 1'b0;
	select_immediate        = IMM_3BIT;
	select_write_address    = WA_FIELD0;

	case (state)

		RESET: begin
		end

		FETCH: begin
		end

		DECODE: begin
		end

		BR: begin
			op1_mux_select   = OP1_PC;
			op2_mux_select   = OP2_IMM;
			select_immediate = IMM_5BIT;
			alu_add_sub      = 1'b0;
			commit_branch    = 1'b1;
		end

		BRZ: begin
			op1_mux_select   = OP1_PC;
			op2_mux_select   = OP2_IMM;
			select_immediate = IMM_5BIT;
			alu_add_sub      = 1'b0;
			commit_branch    = register0_is_zero;
			increment_pc     = ~register0_is_zero;
		end

		ADDI: begin
			op1_mux_select       = OP1_REG;
			op2_mux_select       = OP2_IMM;
			select_immediate     = IMM_3BIT;
			alu_add_sub          = 1'b0;
			result_mux_select    = 1'b1;
			select_write_address = WA_FIELD0;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		SUBI: begin
			op1_mux_select       = OP1_REG;
			op2_mux_select       = OP2_IMM;
			select_immediate     = IMM_3BIT;
			alu_add_sub          = 1'b1;
			result_mux_select    = 1'b1;
			select_write_address = WA_FIELD0;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		SR0: begin
			op1_mux_select       = OP1_R0;
			op2_mux_select       = OP2_IMM;
			select_immediate     = IMM_4BIT;
			alu_set_low          = 1'b1;
			result_mux_select    = 1'b1;
			select_write_address = WA_R0;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		SRH0: begin
			op1_mux_select       = OP1_R0;
			op2_mux_select       = OP2_IMM;
			select_immediate     = IMM_4BIT;
			alu_set_high         = 1'b1;
			result_mux_select    = 1'b1;
			select_write_address = WA_R0;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		CLR: begin
			result_mux_select    = 1'b0;
			select_write_address = WA_FIELD0;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		MOV: begin
			op1_mux_select       = OP1_REG;
			op2_mux_select       = OP2_IMM;
			select_immediate     = IMM_ZERO;
			alu_add_sub          = 1'b0;
			result_mux_select    = 1'b1;
			select_write_address = WA_FIELD1;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		MOVA: begin
			op1_mux_select       = OP1_REG;
			op2_mux_select       = OP2_IMM;
			select_immediate     = IMM_ZERO;
			alu_add_sub          = 1'b0;
			result_mux_select    = 1'b1;
			select_write_address = WA_FIELD0;
			write_reg_file       = 1'b1;
			increment_pc         = 1'b1;
		end

		MOVR: begin
			load_temp_register = 1'b1;
		end

		MOVR_STAGE2: begin
			if (temp_is_zero) begin
				increment_pc = 1'b1;
			end
			else begin
				op1_mux_select          = OP1_R2;
				op2_mux_select          = OP2_TWO;
				alu_add_sub             = temp_is_negative; // subtract when negative
				result_mux_select       = 1'b1;
				select_write_address    = WA_R2;
				write_reg_file          = 1'b1;
				decrement_temp_register = temp_is_positive;
				increment_temp_register = temp_is_negative;
				start_delay_counter     = 1'b1; // load delay from R3 here
			end
		end

		MOVR_DELAY: begin
			enable_delay_counter = 1'b1;
		end

		MOVRHS: begin
			load_temp_register = 1'b1;
		end

		MOVRHS_STAGE2: begin
			if (temp_is_zero) begin
				increment_pc = 1'b1;
			end
			else begin
				op1_mux_select          = OP1_R2;
				op2_mux_select          = OP2_ONE;
				alu_add_sub             = temp_is_negative;
				result_mux_select       = 1'b1;
				select_write_address    = WA_R2;
				write_reg_file          = 1'b1;
				decrement_temp_register = temp_is_positive;
				increment_temp_register = temp_is_negative;
				start_delay_counter     = 1'b1; // load delay from R3 here
			end
		end

		MOVRHS_DELAY: begin
			enable_delay_counter = 1'b1;
		end

		PAUSE: begin
			start_delay_counter = 1'b1;
		end

		PAUSE_DELAY: begin
			enable_delay_counter = 1'b1;
			if (delay_done)
				increment_pc = 1'b1;
		end

		default: begin
			// keep defaults
		end
	endcase
end

endmodule