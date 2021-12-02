.main
    MOVIL  r0  1   # x = 1
    MOVIL  r1  10  # y = 10
    MOVIL  r9  5   # .L2
    JUC    r9
.L3
    SUBI   r1  1   # y--
.L2
    CMP    r0  r1  # x != y?
    MOVIL  r10 4   # .L3
    JNE    r10
    ADD    r2  r1  # store the final value of y in r2
