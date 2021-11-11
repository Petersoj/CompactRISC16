main: MOVIL r0, 5   // x = 5
      MOVIL r9, 4
      JUC   r9
.L3:  SUBI  r0, 1
.L2:  CMPI  r0, 5
      MOVIL r10, 3
      JEQ   r10
      ADD   r1, r0  // x = 4
