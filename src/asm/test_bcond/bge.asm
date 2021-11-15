.main: ADDI   r0, 0    // r0 = 0
       ADDI   r14, 4   // int i = 4
.L1:   ADDI    r0, 1   // x++
       SUBI    r14, 1  // i--
       CMPI     r14, 0  // i - 0, jump if i >= 0;
       BGE     -4      // jump back 3 lines
       ADD     r1, r0  // r1 should get final value of x, which is 5
