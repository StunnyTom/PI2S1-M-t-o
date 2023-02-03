#ifndef TOUT_H
#define TOUT_H

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <errno.h>
#include <string.h>

/* Structure AVL  */
typedef struct arbre { 
  Donnee elmt;
  struct arbre* fd;
  struct arbre* fg;
  int equilibre; 
} Arbre;

// structure donnee dans les AVL
typedef struct donnee {
  double traiter;
  char* reste;
} Donnee;

/* Structure ABR  */
typedef struct arb { 
  DonneeABR elmt;
  struct arb* fd;
  struct arb* fg;
} ABR;

// structure donneeABR dans les ABR
typedef struct {
  double traiter;
  char* reste;
} DonneeABR;


ABR* creerABR(DonneeABR a);
ABR *insertionABR(ABR *a, DonneeABR e);
void ecrireABR(FILE* fp,DonneeABR e );
void parcoursInfixe(FILE* fp, ABR* a);
void reverseParcoursInfixe(FILE* fp, ABR* a);
ABR *recuperationABR(char *fichierEntree);
void ecritureFSortieABR(char *fichierSortie, ABR *rempli, int r);
void suppressionABR(ABR* a);
int max(int a, int b) ;
int min(int a, int b) ; 
int max2(int a, int b, int c);
int min2(int a, int b, int c) ;
Arbre *creerAVL(Donnee a) ;
Arbre *insertionAVL(Arbre *a, Donnee e, int *h) ;
Arbre *equilibrageAVL(Arbre *a) ;
Arbre *rotationDroite(Arbre *a) ;
Arbre *rotationGauche(Arbre *a) ;
Arbre *doubleRotationDroite(Arbre *a);
Arbre *doubleRotationGauche(Arbre *a) ;
void ecrireAVL(FILE* fp,Donnee e ) ;
void parcoursInfixeAVL(Arbre *a, FILE *f) ;
void reverseParcoursInfixeAVL(Arbre *a, FILE *f) ;
void ecritureFSortieAVL(char *fichierSortie, Arbre *rempli, int r) ;
Arbre *recuperationAVL(char *fichierEntree) ;
void suppressionAVL(Arbre* a);



#endif