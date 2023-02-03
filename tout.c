#include"tout.h"


//créer un arbre
ABR* creerABR(DonneeABR a){ 
  ABR* noeud = malloc(sizeof(ABR)); 
    if (noeud == NULL){
      printf("Problème d'allocation mémoire");
      exit(1);
    }
  noeud->elmt.traiter = a.traiter; 
  noeud->elmt.reste = a.reste;
  noeud->fd = NULL; 
  noeud->fg = NULL; 
return noeud; 
}

// insérer un élément de type DonneeABR dans l'arbre
ABR *insertionABR(ABR *a, DonneeABR e) {
  if (a == NULL) {
    return creerABR(e);
  } 
  else if (e.traiter < a->elmt.traiter) {
    a->fg = insertionABR(a->fg, e);
  } 
  else if (e.traiter >= a->elmt.traiter) { // gérer les doublons avec le ou égal
    a->fd = insertionABR(a->fd, e);
  } 
  return a;
}

// fonction d'écriture avec fprintf
void ecrireABR(FILE* fp, DonneeABR e ) {
  fprintf(fp, "%lf;%s", e.traiter,e.reste);
  }

// parcours dans l'ordre croissant
void parcoursInfixe(FILE* fp, ABR* a) {
  if (a != NULL) {
    parcoursInfixe(fp,a->fg);
    ecrireABR(fp,a->elmt);
    parcoursInfixe(fp,a->fd);
  }
}

// fonction de tri décroissant
void reverseParcoursInfixe(FILE* fp, ABR* a) {
  if (a != NULL) {
    reverseParcoursInfixe(fp,a->fd);
    ecrireABR(fp,a->elmt);
    reverseParcoursInfixe(fp,a->fg);
  }
}

// récupère les données du fichier d'entrée envoyé par le Shell dans un ABR
ABR *recuperationABR(char *fichierEntree) {
  FILE *fp;
  char *c;
  ABR *arbreRempli;
  int *h;
  double temp;
  DonneeABR recuperee;

  // Ouverture du fichier
  fp = fopen(fichierEntree, "r");
  if (fp == NULL) {
    printf("problème d'ouverture du fichier");
    return NULL;
  }
  while (fscanf(fp, "%lf;%s", &(temp), c) !=EOF) { // tant que l'on est pas arrivé à la fin de notre fichier
    recuperee.traiter = temp;
    recuperee.reste = c;
    arbreRempli = insertionABR(arbreRempli, recuperee);
  }
  fclose(fp); // fermeture du fichier

  return arbreRempli;
}

// fonction d'écriture de l'ABR trié dans le fichier de sortie
void ecritureFSortieABR(char *fichierSortie, ABR *rempli, int r) {
  FILE *fp;
  char *c;
  ABR *arbreRempli;
  int *h;
  double temp;
  DonneeABR recuperee;

  // Ouverture du fichier
  fp = fopen(fichierSortie, "w");
  if (fp == NULL)
    printf("problème d'ouverture du fichier");
  if (r == 0)
    parcoursInfixe(fp,rempli);
  else
    reverseParcoursInfixe(fp,rempli);
}

// fonction utilisée pour free les ABR 
void suppressionABR(ABR* a){
  if (a->fd != NULL){
    suppressionABR(a->fd);
  }
  if (a->fg != NULL){
    suppressionABR(a->fg);
  }
  free(a);
}


////////////////////////////////////////////
////////////////////////////////////////////


int max(int a, int b) { 
  return (a < b ? b : a); 
  }

int min(int a, int b) { 
  return (a < b ? a : b); 
  }

int max2(int a, int b, int c) {
  if (max(a, b) <= c)
    return c;
  if (max(a, c) <= b)
    return b;
  else
    return a;
}

int min2(int a, int b, int c) {
  if (min(a, b) >= c)
    return c;
  if (min(a, c) >= b)
    return b;
  else
    return a;
}

// Créer un AVL
Arbre *creerAVL(Donnee a) {
  Arbre *noeud = malloc(sizeof(Arbre));
  if (noeud == NULL) {
    printf("Problème d'allocation mémoire");
    exit(1);
  }
  noeud->elmt.traiter = a.traiter;
  noeud->elmt.reste = a.reste;
  noeud->fd = NULL;
  noeud->fg = NULL;
  noeud->equilibre = 0;
  return noeud;
}

// Insertion dans un AVL:
Arbre *insertionAVL(Arbre *a, Donnee e, int *h) {
  if (a == NULL) {
    *h = 1;
    return creerAVL(e);
  } else if (e.traiter < a->elmt.traiter) {
    a->fg = insertionAVL(a->fg, e, h);
    *h = -(*h);
  } else if (e.traiter > a->elmt.traiter) {
    a->fd = insertionAVL(a->fd, e, h);
  } else {
    *h = 0;
    return a;
  }
  if (*h != 0) {
    a->equilibre = a->equilibre + (*h);
    a = equilibrageAVL(a);
  }

  if (a->equilibre == 0) {
    *h = 0;
  }
  if (a->equilibre) {
    *h = 1;
    return a;
  }
}

// Equilibrage dans un AVL
Arbre *equilibrageAVL(Arbre *a) {
  if (a->equilibre >= 2) {
    if (a->fd->equilibre >= 0) {
      return rotationGauche(a);
    } else {
      return doubleRotationGauche(a);
    }
  } else if (a->equilibre <= -2) {
    if (a->fg->equilibre <= 0) {
      return rotationDroite(a);
    } else {
      return doubleRotationGauche(a);
    }
  }
}

// Rotations dans les AVL:
Arbre *rotationDroite(Arbre *a) {

  Arbre *pivot;
  int eq_a, eq_p;

  pivot = a->fg;
  a->fg = pivot->fd;
  pivot->fd = a;
  eq_a = a->equilibre;
  eq_p = pivot->equilibre;
  a->equilibre = eq_a - min(eq_p, 0) + 1;
  pivot->equilibre = max2(eq_a + 2, eq_a + eq_p + 2, eq_p + 1);
  a = pivot;
  return a;
}

Arbre *rotationGauche(Arbre *a) {

  Arbre *pivot;
  int eq_a, eq_p;

  pivot = a->fd;
  a->fd = pivot->fg;
  pivot->fg = a;
  eq_a = a->equilibre;
  eq_p = pivot->equilibre;
  a->equilibre = eq_a - max(eq_p, 0) + 1;
  pivot->equilibre = min2(eq_a - 2, eq_a + eq_p - 2, eq_p - 1);
  a = pivot;
  return a;
}

Arbre *doubleRotationDroite(Arbre *a) {
  a->fg = rotationGauche(a->fg);
  return rotationDroite(a);
}

Arbre *doubleRotationGauche(Arbre *a) {
  a->fd = rotationDroite(a->fd);
  return rotationGauche(a);
}

// fonction d'écriture avec fprintf
void ecrireAVL(FILE* fp,Donnee e ) {
  fprintf(fp, "%lf;%s", e.traiter,e.reste);
  }

// parcours dans l'ordre croissant
void parcoursInfixeAVL(Arbre *a, FILE *f) {
  if (a != NULL) {
    parcoursInfixeAVL(a->fg, f);
    ecrireAVL(f,a->elmt);
    parcoursInfixeAVL(a->fd, f);
  }
}

// parcours dans l'ordre décroissant
void reverseParcoursInfixeAVL(Arbre *a, FILE *f) {
  if (a != NULL) {
    reverseParcoursInfixeAVL(a->fd, f);
    ecrireAVL(f,a->elmt);
    reverseParcoursInfixeAVL(a->fg, f);
  }
}

// écriture d'AVL trié dans le fichier de sortie 
void ecritureFSortieAVL(char *fichierSortie, Arbre *rempli, int r) {
  FILE *fp;
  char *c;
  Arbre *arbreRempli;
  int *h;
  double temp;
  Donnee recuperee;

  // Ouverture du fichier
  fp = fopen(fichierSortie, "w");
  if (fp == NULL)
    printf("problème d'ouverture du fichier");
  if (r == 0)
    parcoursInfixeAVL(rempli, fp);
  else
    reverseParcoursInfixeAVL(rempli, fp);
}

// fonction de récupération des données d'un fichier d'entrée et les mettre dans un AVL
Arbre *recuperationAVL(char *fichierEntree) {
  FILE *fp;
  char *c;
  Arbre *arbreRempli;
  int *h;
  double temp;
  Donnee recuperee;

  // Open the file
  fp = fopen(fichierEntree, "r");
  if (fp == NULL) {
    printf("problème d'ouverture du fichier");
    return NULL;
  }
  while (fscanf(fp, "%lf;%s", &(temp), c) !=EOF) { // tant que l'on est pas arrivé à la fin de notre fichier
    recuperee.traiter = temp;
    recuperee.reste = c;
    arbreRempli = insertionAVL(arbreRempli, recuperee, h);
  }
  fclose(fp); // Close the file

  return arbreRempli;
}

// fonction utilisée pour free les avl 
void suppressionAVL(Arbre* a){
  if (a->fd != NULL){
    suppressionAVL(a->fd);
  }
  if (a->fg != NULL){
    suppressionAVL(a->fg);
  }
  free(a);
}

/////////////////////////////////////////////////
////////////// FONCTION MAIN ////////////////////
/////////////////////////////////////////////////

int main(int argc, char* argv[]){
  char *fEntree, *fSortie, *tri; 
  int e=0,s=0,av=0,r=0,ab=0,ta=0;
  Arbre* avl=NULL;
  ABR* Abrr=NULL;
  //Tableau table={0,NULL};
  
for (int i = 1; i < argc; i++){  
    if (strcmp (argv[i], "-f") == 0){  
      fEntree = argv[i+1]; // fichier d'entrée prend ce qu'il y a après le -f
      i++;
      e++;
      if (e>1) return 1; // vérification que -f n'a été rentrée qu'une fois
    }  
    else if (strcmp (argv[i], "-o") == 0){
      fSortie = argv[i+1];
      i++;
      s++;
      if (s>1) return 1; // vérification que -o n'a été rentrée qu'une fois
    }
    else if (strcmp (argv[i], "-r") == 0){
      r++;
      if (r>1) return 1; // vérification que -r n'a été rentrée qu'une fois
    } 
    else if (strcmp (argv[i], "--avl") == 0){
      tri = "avl";
      av++;
      if (av>1) return 1; // vérification que --avl n'a été rentrée qu'une fois
    } 
   else if (strcmp (argv[i], "--abr") == 0){
      tri = "abr";
      ab++;
      if (ab>1) return 1; // vérification que --abr n'a été rentrée qu'une fois
    } 
   else if (strcmp (argv[i], "--tab") == 0){
      tri = "tab";
      ta++;
      if (ta>1) return 1; // vérification que -tab n'a été rentrée qu'une fois
    } 
    else return 1;
  }

  if(e==0){//lorsque'aucun fichier d'entrée n'est donné
    return 1;
  }
  if(s==0){//lorsque'aucun fichier de sortie n'est donné
    return 1;
  } 

// vérification du fichier de sortie
  FILE* fp;
  // ouverture du fichier
  fp = fopen(fSortie, "r");
  if (fp == NULL) {
    return 3;
  }
  fclose(fp); // fermeture du fichier

  //regardons quel tri nous devons effectuer
  if(av==1){//s'il s'agit de l'avl
    //on recupere toutes les donnees dans un avl
    avl=recuperationAVL(fEntree);
    if(avl==NULL)
      return 2;// on a pas reussi a ouvrir le fichier d'entree
    //maintenant il faut les ecrire dans le fichier de sortie
    ecritureFSortieAVL(fEntree, avl, r);
    return 0;
  }

  if(ab==1){//s'il s'agit de l'abr
    //on recupere toutes les donnees dans un abr
    Abrr=recuperationABR(fEntree);
    if(Abrr==NULL)
      return 2;// on a pas reussi a ouvrir le fichier d'entree
    //maintenant il faut les ecrire dans le fichier de sortie
    ecritureFSortieABR( fEntree, Abrr, r);
    return 0;
  }

// partie des tableaux que l'on n'a pas implémenté
 /* if(ta==1){//s'il s'agit de l'abr
    //on recupere toutes les donnees dans un abr
    table=recuperation(fEntree);
    if(ta==NULL)
      return 2;// on a pas reussi a ouvrir le fichier d'entree
    //maintenant il faut les ecrire dans le fichier de sortie
    ecritureFSortie( fEntree, ta, r);
    return 0;
  }
  */

  return 1;
}