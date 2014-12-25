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
	li $a3, 0
	la $a0, grille
	jal recherche_algorithme

	jal exit

# Mettre des appels de fonctions dans cette zone.
# ------------------------------------------------- #
#						    #
#		MEYER Cyril			    #
#	Projet architecture L2S3		    #
#						    #
# ------------------------------------------------- #

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
		# for( $t1 = $t0+1 ; $t1 != 9 ; $t1++ )
		add $t1, $t0, 1
		#	$t4 = $t2 (adress + n) + 9
		add $t4, $t2, 9

		colonne_n_valide_boucle_2:

			lb $t5, 0($t4)

			beq $t5, 0, colonne_n_valide_0
			beq $t5, $t3, colonne_n_valide_false
			colonne_n_valide_0:

			add $t1, $t1, 1
			add $t4, $t4, 9
			bne $t1, 9, colonne_n_valide_boucle_2
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


# ------------------------------------------------- #
# func :	ligne_n_valide
# args :	$a0 : adress table
# 		$a1 : n° ligne (0-8)
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur global
# 		$t1 : compteur sous boucle
#		$t2 : adress + n
# 		$t3 : grille[ $t2 ]
#		$t4 : adress + n + $t1
#		$t5 : grille[ $t4 ]
# ------------------------------------------------- #

ligne_n_valide:
	li $t0, 0

	# $t2 = $a1 * 9 + $a0
	mul $t2, $a1, 9
	add $t2, $t2, $a0

	# for( $t0=0 ; $t0!=9 ; $t0++ )
	ligne_n_valide_boucle_1:
		lb $t3, 0($t2)
		
		# for( $t1 = $t0+1 ; $t1 != 9 ; $t1++ )
		add $t1, $t0, 1
		#	$t4 = $t2 (adress + n) + 1
		add $t4, $t2, 1
		
		ligne_n_valide_boucle_2:

			lb $t5, 0($t4)
			
			beq $t5, 0, ligne_n_valide_0
			beq $t5, $t3, ligne_n_valide_false
			ligne_n_valide_0:

			add $t1, $t1, 1
			add $t4, $t4, 1
			bne $t1, 9, ligne_n_valide_boucle_2

		add $t2, $t2, 1
		add $t0, $t0, 1
		bne, $t0, 8, ligne_n_valide_boucle_1

		ligne_n_valide_true:
			li $v0, 0
			j ligne_n_valide_end
		ligne_n_valide_false:
			li $v0, 1
		ligne_n_valide_end:
	jr $ra

# ------------------------------------------------- #
# func :	carre_n_valide_index_base
# args :	$a0 : n° bloc (0-8)
# retu :	$v0 : index de base
# prec :	0 <= $a0 <= 8
# vars :	$t0 : n
# 		$t1 : (n mod 3) * 3
#		$t2 : (x / 3) * 3 * 9
# ------------------------------------------------- #

carre_n_valide_index_base:
	# save $ra
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	# $t0 = $a0
	move $t0, $a0
	# $t0 % 3
	li $a1, 3
	jal modulo
	# $v0 = n mod 3
	
	# $t1 = 3 * $v0
	mul $t1, $v0, 3
	# $t2 = $t0 * 3
	div $t2, $t0, 3
	# $t2 *= 3
	mul $t2, $t2, 3
	# $t2 *= 9
	mul $t2, $t2, 9
	# $v0 = $t1 + $t2
	add $v0, $t1, $t2
	
	# restaure $a0
	move $a0,$t0
	# load $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
# ------------------------------------------------- #
# func :	carre_n_valide_index_n
# args :	$a0 : index base
#		$a1 : n
# retu :	$v0 : index i
# prec :	0 <= $a0 <= 8
#		0 <= $a1 <= 8
# vars :	$t0 : $a0
#		$t1 : $a1
#		$t3 : $t1 mod 3
# ------------------------------------------------- #
carre_n_valide_index_n:
	# save $t0
	add $sp, $sp, -4
	sw $t0, 0($sp)
	# save $t1
	add $sp, $sp, -4
	sw $t1, 0($sp)

	move $t0, $a0
	move $t1, $a1
	
	# save $ra
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	# $t1 % 3
	move $a0,$t1
	li $a1, 3
	jal modulo
	
	# load $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	move $t3, $v0
	
	div $t1, $t1, 3
	mul $t1, $t1, 9
	
	add $v0, $t1, $t3
	add $v0, $v0, $t0
	
	# load $t1
	lw $t1, 0($sp)
	add $sp, $sp, 4
	# load $t0
	lw $t0, 0($sp)
	add $sp, $sp, 4
	
	jr $ra

# ------------------------------------------------- #
# func :	carre_n_valide
# args :	$a0 : adress table
# 		$a1 : n° carre (0-8)
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur boucle 1
# 		$t1 : compteur boucle 2
#		$t2 : adress base
# 		$t3 : adress
#		$t4 : mem[$t3]
#		$t5 : adress boucle 2
#		$t6 : mem[$t5]
#		$t7 : sauvegarde $a0
#		$t8 : sauvegarde $a1
# ------------------------------------------------- #
carre_n_valide:
	# save $ra
	add $sp, $sp, -4
	sw $ra, 0($sp)
	move $t7, $a0
	move $t8, $a1
	
	move $a0, $a1
	jal carre_n_valide_index_base
	move $t2, $v0
	
	# $t0 : i
	# for i=0 ; i<8; i++
	li $t0, 0 
	carre_n_valide_boucle_1:		
		move $a0, $t2
		move $a1, $t0
		
		jal carre_n_valide_index_n
		# $t3 : adress actuel (0-80)
		move $t3, $v0
		
		add $t3, $t3, $t7
		lb $t4, 0($t3)
		
		# $t1 : j
		# for j=i+1 ; j<9; j++
		add $t1, $t0, 1
		carre_n_valide_boucle_2:
			
			move $a0, $t2
			move $a1, $t1
			
			jal carre_n_valide_index_n
			# $t3 : adress actuel (0-80)
			move $t5, $v0
			
			add $t5, $t5, $t7
			lb $t6, 0($t5)
			
			beq $t6, 0, carre_n_valide_0
			beq $t4, $t6, carre_n_valide_false
			carre_n_valide_0:
			
			add $t1, $t1, 1
			blt, $t1, 9, carre_n_valide_boucle_2
		add $t0, $t0, 1
		blt $t0, 8, carre_n_valide_boucle_1
	
	carre_n_valide_true:
		li $v0, 0
		j carre_n_valide_end
	carre_n_valide_false:
		li $v0, 1
	carre_n_valide_end:
	
	# load $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra

# ------------------------------------------------- #
# func :	colonnes_valides
# args :	$a0 : adress table
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur boucle 1
# ------------------------------------------------- #
colonnes_valides:
	# $t0 : i
	# for i=0 ; i<9 ; i++
	li $t0, 0
	colonnes_valides_boucle_1:
		# save $ra
		add $sp, $sp, -4
		sw $ra, 0($sp)
		# save $t0
		add $sp, $sp, -4
		sw $t0, 0($sp)
		# save $a0
		add $sp, $sp, -4
		sw $a0, 0($sp)
		
		move $a1, $t0
		jal colonne_n_valide
		
		# load $a0
		lw $a0, 0($sp)
		add $sp, $sp, 4	
		# load $t0
		lw $t0, 0($sp)
		add $sp, $sp, 4	
		# load $ra
		lw $ra, 0($sp)
		add $sp, $sp, 4	
		
		beq $v0, 1, colonnes_valides_false
		
		add $t0, $t0, 1
		blt $t0, 9, colonnes_valides_boucle_1
	
	colonnes_valides_true:
		li $v0, 0
		j colonnes_valides_end
	colonnes_valides_false:
		li $v0, 1
	colonnes_valides_end:
	
	jr $ra
# ------------------------------------------------- #
# func :	lignes_valides
# args :	$a0 : adress table
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur boucle 1
# ------------------------------------------------- #
lignes_valides:
	# $t0 : i
	# for i=0 ; i<9 ; i++
	li $t0, 0
	lignes_valides_boucle_1:
		# save $ra
		add $sp, $sp, -4
		sw $ra, 0($sp)
		# save $t0
		add $sp, $sp, -4
		sw $t0, 0($sp)
		# save $a0
		add $sp, $sp, -4
		sw $a0, 0($sp)
		
		move $a1, $t0
		jal ligne_n_valide
		
		# load $a0
		lw $a0, 0($sp)
		add $sp, $sp, 4	
		# load $t0
		lw $t0, 0($sp)
		add $sp, $sp, 4	
		# load $ra
		lw $ra, 0($sp)
		add $sp, $sp, 4	
		
		beq $v0, 1, lignes_valides_false
		
		add $t0, $t0, 1
		blt $t0, 9, lignes_valides_boucle_1
	
	lignes_valides_true:
		li $v0, 0
		j lignes_valides_end
	lignes_valides_false:
		li $v0, 1
	lignes_valides_end:
	
	jr $ra
# ------------------------------------------------- #
# func :	carres_valides
# args :	$a0 : adress table
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur boucle 1
# ------------------------------------------------- #
carres_valides:
	# $t0 : i
	# for i=0 ; i<9 ; i++
	li $t0, 0
	carres_valides_boucle_1:
		# save $ra
		add $sp, $sp, -4
		sw $ra, 0($sp)
		# save $t0
		add $sp, $sp, -4
		sw $t0, 0($sp)
		# save $a0
		add $sp, $sp, -4
		sw $a0, 0($sp)
		
		move $a1, $t0
		jal carre_n_valide
		
		# load $a0
		lw $a0, 0($sp)
		add $sp, $sp, 4	
		# load $t0
		lw $t0, 0($sp)
		add $sp, $sp, 4	
		# load $ra
		lw $ra, 0($sp)
		add $sp, $sp, 4	
		
		beq $v0, 1, carres_valides_false
		
		add $t0, $t0, 1
		blt $t0, 9, carres_valides_boucle_1
	
	carres_valides_true:
		li $v0, 0
		j carres_valides_end
	carres_valides_false:
		li $v0, 1
	carres_valides_end:
	
	jr $ra

# ------------------------------------------------- #
# func :	carres_valides
# args :	$a0 : adress table
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	/
# ------------------------------------------------- #
sudoku_valides:
	# save $ra
	add $sp, $sp, -4
	sw $ra, 0($sp)
	# save $a0
	add $sp, $sp, -4
	sw $a0, 0($sp)
	
	jal lignes_valides
	beq $v0, 1, sudoku_valides_false
	
	# load $a0, ne touche pas $sp
	lw $a0, 0($sp)
	jal colonnes_valides
	beq $v0, 1, sudoku_valides_false
	
	# load $a0, ne touche pas $sp
	lw $a0, 0($sp)
	jal carres_valides
	beq $v0, 1, sudoku_valides_false
	
	# load $a0, $ra
	lw $a0, 0($sp)
	add $sp, $sp, 4
	lw $ra, 0($sp)
	add $sp, $sp, 4	
	
	sudoku_valides_true:
		li $v0, 0
		j sudoku_valides_end
	sudoku_valides_false:
		# load $a0, $ra	
		lw $a0, 0($sp)
		add $sp, $sp, 4	
		lw $ra, 0($sp)
		add $sp, $sp, 4	
		li $v0, 1
	sudoku_valides_end:
	
	
	
	jr $ra

# ------------------------------------------------- #
# func :	recherche_algorithme_no_0
# args :	$a0 : adress table
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur 1
#		$t2 : adress tableau + $t0
#		$t3 : mem[$t2]
# ------------------------------------------------- #
recherche_algorithme_no_0:
	# i : $t0
	# for i=0; i<81; i++
	li $t0, 0
	recherche_algorithme_no_0_boucle_1:	
		# si grille[i] == 0
		# $v0 = 1
		# sinon continuer
		add $t2, $t0, $a0
		lb $t3, 0($t2)
		beq $t3, 0, recherche_algorithme_no_0_false
		add $t0, $t0, 1
		blt $t0, 81, recherche_algorithme_no_0_boucle_1

	recherche_algorithme_no_0_true:
		li $v0, 0
		j sudoku_valides_end
	recherche_algorithme_no_0_false:
		li $v0, 1
	recherche_algorithme_no_0_end:
	jr $ra
# ------------------------------------------------- #
# func :	recherche_algorithme
# args :	$a0 : adress table
# retu :	$v0 : 1 = invalide, 0 = valide
# prec :	table : 81 bytes
# vars :	$t0 : compteur 1
#		$t1 : compteur 2
#		$t2 : adress tableau + $t0
#		$t3 : mem[$t2]
# ------------------------------------------------- #
recherche_algorithme:
	# save $ra
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal sudoku_valides
	
	# load $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4	
	
	beq $v0, 1, recherche_algorithme_end
	
	# i : $t0
	# for i=0; i<81; i++
	li $t0, 0
	recherche_algorithme_boucle_1:	
		# si grille[i] != 0
		# fin
		add $t2, $t0, $a0
		lb $t3, 0($t2)
		bne $t3, 0, recherche_algorithme_boucle_1_fin
		# sinon
		# j : $t1
		# for j=1 ; j<=9 ; j++
		# grille[i] = j
		# appel recursif
		# remettre a 0 grille[i] pour les autres appels
		li $t1, 1
		
		recherche_algorithme_boucle_2:
		
			sb $t1, 0($t2)
			
			sw $t2, -4($sp)
			sw $t1, -8($sp)
			sw $t0, -12($sp)
			sw $ra, -16($sp)
			sw $a0, -20($sp)
			add $sp, $sp, -20
			
			jal recherche_algorithme
			
			lw $t2, 16($sp)
			lw $t1, 12($sp)
			lw $t0, 8($sp)
			lw $ra, 4($sp)
			lw $a0, 0($sp)
			
			add $sp, $sp, 20
			
			
			add $t1, $t1, 1
			
			ble $t1, 9, recherche_algorithme_boucle_2
			li $t1, 0
			sb $t1, 0($t2)
			j recherche_algorithme_boucle_1_fin2
		
		recherche_algorithme_boucle_1_fin:
		add $t0, $t0, 1
		blt $t0, 81, recherche_algorithme_boucle_1
		recherche_algorithme_boucle_1_fin2:
		
	# save $ra
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal sudoku_valides
	
	beq $v0, 1, recherche_algorithme_false
	
	jal recherche_algorithme_no_0
	
	beq $v0, 1, recherche_algorithme_false
	
	
	jal printArray
	jal newLine
	
	# load $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4	
	
	recherche_algorithme_true:
		li $v0, 0
		j sudoku_valides_end
	recherche_algorithme_false:
		li $v0, 1
		# load $ra
		lw $ra, 0($sp)
		add $sp, $sp, 4
	recherche_algorithme_end:
	jr $ra

# Fin de la zone d'appel de fonctions.

exit:
	li		$v0, 10
	syscall

# End