.main: MOVIL r0, 5   // x = 5
       BUC   1
.L3:   SUBI  r0, 1
.L2:   CMPI  r0, 5
       BEQ   -3      // 1111_1101
       ADD   r1, r0  // x = 4
