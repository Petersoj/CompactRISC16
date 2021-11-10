main:
     MOVI  r0, 1    // x = 1
     MOVI  r1, 10   // y = 10
     JUC   .L2
.L3:
     SUBI  r1, 1    // y--
.L2:
     CMP   r0, r1   // x != y?
     JNE   .L3
     ADD   r2, r1   // store the final value of y in r2