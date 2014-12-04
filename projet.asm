.data
grille: .byte 81

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
	
	li $t6, 0
	
	tagule:
	la $a0, grille
	move $a1, $t6
	jal colonne_n_valide
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	add $t6, $t6, 1
	bne $t6, 9, tagule
	
	jal exit
	
# Mettre des appels de fonctions dans cette zone.

# ------------------------------------------------- #
# func :	colonne_n_valide
# args :	$a0 : adress table
# 		$a1 : n° colonne (0-8)
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur global
# 		$t1 : compteur sous boucle
#		$t2 : adress + n
# 		$t3 : grille[ $t2 ]
#		$t4 : adress + n + $t1
#		$t5 : grille[ $t4 ]
# ------------------------------------------------- #

colonne_n_valide:
	li $t0, 0
	
	# $t2 = $a0 + $a1 (adress grille[n]
	move $t2, $a0
	add $t2, $t2, $a1
	
	# for( $t0=0 ; $t0!=9 ; $t0++ )
	colonne_n_valide_boucle_1:
		lb $t3, 0($t2)
		
		#li $v0, 1
		#move $a0, $t3
		#syscall
		#li		$v0, 11
		#li		$a0, 10
		#syscall
		
		# for( $t1 = $t0+1 ; $t1 != 9 ; $t1++ )
		add $t1, $t0, 1
		#	$t4 = $t2 (adress + n) + 9
		add $t4, $t2, 9
		
		colonne_n_valide_boucle_2:
			
			lb $t5, 0($t4)
			
			beq $t5, 0, colonne_n_valide_0
			beq $t5, $t3, colonne_n_valide_false
			colonne_n_valide_0:
			
			#li $v0, 1
			#move $a0, $t5
			#syscall
			
			add $t1, $t1, 1
			add $t4, $t4, 9
			bne $t1, 9, colonne_n_valide_boucle_2
		
		
		#li		$v0, 11
		#li		$a0, 10
		#syscall
		
		add $t2, $t2, 9
		add $t0, $t0, 1
		bne, $t0, 8, colonne_n_valide_boucle_1
		
		colonne_n_valide_true:
			li $v0, 0
			j colonne_n_valide_end
		colonne_n_valide_false:
			li $v0, 1
		colonne_n_valide_end:
	jr $ra


# Fin de la zone d'appel de fonctions.

exit: 
	li		$v0, 10
	syscall

# End
