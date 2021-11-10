main:
     MOVIL r0, 5   // x = 5
     JUC   1
.L3:
     SUBI  r0, 1
.L2:
     CMPI  r0, 5
     JEQ   .L3
     ADD   r1, r0  // x = 4