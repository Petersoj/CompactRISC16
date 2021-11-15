.main:  MOVIL  rsp, 0xFF   # rsp is 0xFF (0b1111_1111)
        MOVIL  r11, 1      # First arg is 1
        MOVIL  r12, 2      # Second arg is 2
        CALLD  0x005       # Like CALL .add_1, but using CALLD instruction
        MOVIL  r0,  0x0F
        STORE  r0,  r11    # Mem[0x0F] = 2
        SUBI   r0,  1      # Mem[0x0E] = 3
        STORE  r0,  r12
        BUC    3           # Jump to end of program
.add_1: ADDI   r11, 1      # Add 1 to first arg
        ADDI   r12, 1      # Add 1 to second arg
        RET
