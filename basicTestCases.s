nop
nop
addi $1, $0, 1
j 5
addi $1, $1, 1
addi $1, $1, 2
addi $5, $0, 0
j 9
add $5, $5, $1
add $5, $5, $1
addi $2, $0, 1
addi $3, $0, 1
addi $4, $0, 0
bne $2, $3, 1
addi $4, $4, 1
addi $4, $4, 1
addi $6, $0, 0
bne $2, $0, 1
addi $6, $6, 1
addi $6, $6, 1
addi $12, $0, 0
addi $13, $0, 0
jal 24
addi $12, $12, 1
addi $12, $12, 1
add $13, $0, $31
addi $14, $0, 0
addi $15, $0, 30
jr $15
addi $14, $14, 1
addi $14, $14, 1
addi $8, $0, 0
addi $9, $0, 1
addi $11, $0, 2
jal 39
addi $7, $0, 43
sub $8, $8, $9
add $10, $8, $9
jr   $7
addi $8, $8, 1
addi $9, $9, 1
add $10, $8, $9
jr $31
addi $16, $0, 1
addi $17, $0, 1
addi $18, $0, 0
blt $16, $17, 1
addi $18, $18, 1
addi $18, $18, 1
addi $19, $0, 0
blt $0, $16, 1
addi $19, $19, 1
addi $19, $19, 1
addi $20, $0, 0
blt $16, $0, 1
addi $20, $20, 1
addi $20, $20, 1
setx 1
addi $21, $0, 1
bex  61
addi $21, $21, 1
addi $21, $21, 1
addi $21, $21, 1
setx 0
addi $22, $0, 1
bex 66
addi $22, $22, 1
addi $22, $22, 1
