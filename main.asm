.data
grille: .byte 81
liste_9: .byte 9

.text

# Effectue un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
newLine:
	li		$v0, 11
	li		$a0, 10
	syscall
	jr $ra

# Ouverture d'un fichier. 
#	$a0 nom du fichier, 
#	$a1 le flag d'ouverture (0 lecture, 1 ecriture)
# Registres utilises : $v0, $a2
openfile: 
	li   	$v0, 13       # system call for open file
	li   	$a2, 0
	syscall               # open a file (file descriptor returned in $v0)
	jr 		$ra

# Ferme le fichier
#	$a0 le descripteur de fichier qui est ouvert.
# Registres utilises : $v0
closeFile:
	li		$v0, 16 	#Syscall value for closefile.
	syscall
	jr 		$ra

# Lit une ligne du fichier et la mets dans le tableau grille
# Registres utilises : $v0, $a1, $a2
extractionValue:
	li		$v0, 14
	la 		$a1, grille 
	li 		$a2, 81
	syscall
	jr 		$ra

# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-2]
printArray:  
	la	 	$t0, grille
	add 	$sp, $sp, -4		# \ Sauvegarde de la reference du dernier jump
	sw 		$ra, 0($sp)			# /
	li		$t1, 0
	boucle_printArray:
		bge 	$t1, 81, end_printArray 	# Si $t1 est plus grand ou egal a 81 alors branchement a end_printArray
			add 	$t2, $t0, $t1			# $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
			lb		$a0, ($t2)				# load byte at $t2(adress) in $a0
			li		$v0, 1					# code pour l'affichage d'un entier
			syscall
			add		$t1, $t1, 1				# $t1 += 1;
		j boucle_printArray
	end_printArray:
		lw 		$ra, 0($sp)					# \ On recharge la reference 
		add 	$sp, $sp, 4					# / du dernier jump
	jr $ra

# Change array from ascii to integer
# Registres utilises : $t[0-3]
changeArrayAsciiCode:  
	add 	$sp, $sp, -4
	sw 		$ra, 0($sp)
	la		$t3, grille
	li		$t0, 0
	boucle_changeArrayAsciiCode:
		bge 	$t0, 81, end_changeArrayAsciiCode
			add		$t1, $t3, $t0
			lb		$t2, ($t1)
			sub 	$t2, $t2, 48
			sb		$t2, ($t1)
			add		$t0, $t0, 1
		j boucle_changeArrayAsciiCode
	end_changeArrayAsciiCode:
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra

# Fait le modulo (a mod b)
#	$a0 represente le nombre a (doit etre positif)
#	$a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
modulo: 
	sub 	$sp, $sp, 4
	sw 		$ra, 0($sp)
	boucle_modulo:
		blt		$a0, $a1, end_modulo
			sub		$a0, $a0, $a1
		j boucle_modulo
	end_modulo:
	move 	$v0, $a0
	lw 		$ra, 0($sp)
	add 	$sp, $sp, 4
	jr $ra

# Zone de déclaration de vos fonctions

# Fin de la zone de déclaration de vos fonctions

main:
	lw		$a0, 4($a1)
	li 		$a1, 0
	jal	openfile
	move	$a0, $v0
	jal extractionValue
	jal closeFile
	jal changeArrayAsciiCode
	
	jal printArray
	jal newLine
	
	# initialisation liste_9
	la $a0, liste_9
	jal init_liste_9
	
	la $a0, grille		# $a0 = sudoku
	li $a1, 0		# $a1 = colonne n
	jal colonne_n_valide
	move $a0, $v0
	jal print_int
	jal newLine
	
	
	la $a0, grille		# $a0 = sudoku
	li $a1, 1		# $a1 = colonne n
	jal colonne_n_valide
	move $a0, $v0
	jal print_int
	jal newLine
	
	
	la $a0, grille		# $a0 = sudoku
	li $a1, 2		# $a1 = colonne n
	jal colonne_n_valide
	move $a0, $v0
	jal print_int
	jal newLine
	
	jal exit
# Mettre des appels de fonctions dans cette zone.

# func :	colonne_n_valide
#		première ligne n = 0
# util :	$t0, $t1
# args :	$a0 : colonne
#		$a1 : n
# retu :	$v0 : valide : 1 sinon 0
# prec :	0 <= $a1 <= 2
colonne_n_valide:
	li $t1, 9		# $t1 = 9
	mul $t0, $a1, $t1	# $t0 = $a0 * $t1 (9)
	move $t4, $a0
	
	
	
	boucle_elements_colonne:
		# compt : $t1
		# index n : $t0
		# addresse elements : $t2
		# elem[i] : $t3
		# addresse liste : $t4
		add $t1, $t1, -1	# $t1--
		move $t2, $t1		# $t2 = $t1
		add $t2, $t0, $t2	# $t2 += $t0 
		add $t2, $t2, $t4	# $t2 += $t4 
		lb $t3, ($t2)		#
		
		la $t5, liste_9
		move $t6, $t3
		add $t6, $t6, $t5
		lb $t8, 0($t5)
		
		move $a0, $t8
		li $a0, '*'
		li $v0, 11
		syscall
		li $v0, 1
		syscall
		li $a0, '*'
		li $v0, 11
		syscall
		
		#add $t8, $t8, 1
		#sw $t8, 0($t6)
		
		move $a0, $t3
		li $v0, 1
		syscall
		li $a0, '-'
		li $v0, 11
		syscall
		
		# boucle tant que $t1 != 0
		bne $t1, 0, boucle_elements_colonne
		
		li $a0, '_'
		li $v0, 11
		syscall
	
	li $v0, 0		# $v0 = 0
	move $v0, $t0		# $v0 = $t0
	jr $ra			# return

# func :	init_liste_9
# args :	$a0 adress liste
# util :	$t0, $t1
# retu :	/
# prec :	/
init_liste_9:
	li $t0, 0
	li $t1, 0
	boucle_init_liste_9:
		sb $t1, 0($a0)
		add $t0, $t0, 1
		add $a0, $a0, 1
		bne $t0, 9, boucle_init_liste_9
	jr $ra

# func :	print_int
# args :	$a0
# util :	$v0
# retu :	/
# prec :	/
print_int:
	li $v0, 1	# $v0 = 1
	syscall
	jr $ra

# Fin de la zone d'appel de fonctions.

exit: 
	li		$v0, 10
	syscall

# End
