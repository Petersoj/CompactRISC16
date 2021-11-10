     MOVIL  r8, 48 // frame pointer = 48
main:
     MOVIL  r0, 5   // x = 5
     MOVIL  r1, 4   // y = 4
     CMPI   r0, 10  // x < 10
     JGT    .L2
     MOVIL  r1, 3   // y = 3
.L2:
     CMPI   r1, 4   // y > 4
     JLT    .L3
     MOVIL  r0, 4   // x would be 4, but this shouldn't execute.
.L3:
     STORE  r8, r0  // X = 5
     ADDI   r8, 1
     STORE  r8, r1  // y = 3

    
