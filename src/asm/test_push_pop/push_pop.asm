MOVIL  rsp, 0xFF   # rsp is 0xFF (0b1111_1111)
MOVIL  r0,  0x1F
MOVIL  r1,  0x1E
PUSH   r0          # Push 0x1F onto stack
PUSH   r1          # Push 0x1E onto stack
POP    r2          # Pop 0x1E off stack into r2
MOVIL  r9,  0x0F
STORE  r9,  r2     # Mem[0x0F] = 0x1E
POP    r3          # Pop 0x1F off stack into r3
SUBI   r9,  1
STORE  r9,  r3     # Mem[0x0E] = 0x1F
