//Le pseudo-code pour l'algorithme de remplissage. Pour qu'il fonctionne il faut que nos fonctions de vérification de 
//ligne, colonne et blocs ignorent les zéros. 

/*
arguments : la grille de sudoku incomplète
            la position (pos) où l'on se situe dans la grille allant de 0 à 80
sortie :    print une seule grille complétée (et c'est là où est le problème majeur)
*/
void algo_remp (grille sudoku, int pos)
{
    int i=0;
    while ( pos < 81)
    {
        if(sudoku[pos] > 0 )
        algo_remp (sudoku,pos+1);
        else for (i=1;i<9;i++) //quand la case est modifiable on commence à 1 
            {
                sudoku[pos]=i;
                if (colonne_n_valide==0 && ligne_n_valide==0 && carre_n_valide==0 )
                {
                    algo_remp (sudoku,pos+1);
                    sudoku[pos]=0; // on remet les cases modifiables à zero pour se rappeler qu'elles le sont
                                    // mais grâce à la magie de la récursivité je crois qu'on arrive quand même à print
                                    // le sudoku rempli.
                }
                else i++;
            }
    }
    print_sudoku;
}
    
  /*  bref il reste un problème, il faut trouver une super condition qui nous permetterait de trouver toutes les solutions
    et pas qu'une seule. 
*/
