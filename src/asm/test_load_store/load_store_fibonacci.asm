ADDI  r0  0
ADDI  r1  1
ADD   rsp r0
ADD   rsp r1
ADDI  r8  48   # r8 = addr 48, this is effectually the heap pointer
STORE r8  rsp
LOAD  r2  r8   # r2 = r1 + r0 = 1
ADD   r14 r1
ADD   r14 r2
ADDI  r8  1
STORE r8  r14
LOAD  r3  r8   # r3 = r2 + r1 = 2
ADD   r13 r2
ADD   r13 r3
ADDI  r8  1
STORE r8  r13
LOAD  r4  r8   # r4 = r3 + r2 = 3
ADD   r12 r3
ADD   r12 r4
ADDI  r8  1
STORE r8  r12
LOAD  r5  r8   # r5 = r4 + r3 = 5
ADD   r11 r4
ADD   r11 r5
ADDI  r8  1
STORE r8  r11
LOAD  r6  r8   # r6 = r5 + r4 = 8
ADD   r10 r5
ADD   r10 r6
ADDI  r8  1
STORE r8  r10
LOAD  r7  r8   # r7 = r6 + r5 = 13
