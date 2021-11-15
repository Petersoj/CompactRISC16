.main: MOVIL r0, 1    // x = 1
       MOVIL r1, 10   // y = 10
       BUC   1
.L3:   SUBI  r1, 1    // y--
.L2:   CMP   r0, r1   // x != y?
       BNE   -3
       ADD   r2, r1   // store the final value of y in r2
