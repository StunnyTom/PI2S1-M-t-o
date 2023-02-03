Readme.txt 

Projet météo (en développement) : 

Le projet météo consiste en un script qui trie un fichier au format csv passé en paramètre, lequel contient les données météo que l’on souhaite filtrer. Selon le mode choisi par l’utilisateur, le script affichera à terme un ou plusieurs graphiques représentant les données demandées. Des restrictions peuvent être ajoutées, comme un intervalle de dates, ou une limitation géographique. Enfin, l’utilisateur peut choisir une méthode de tri informatique parmi trois choix : un tri dans des tableaux, un tri par ABR, ou un tri par AVL. A noter que le contenu du fichier doit correspondre aux fichiers de “Données météorologiques France” (SYNOP / SMT / OMM), sans quoi le tri sera effectué sur des données faussées.

Lancer le projet : 
ouvrir un terminal shell
rentrer dans le répertoire du projet (commande cd)
entrer la commande make (make doit être préalablement installé sur l’appareil)
entrer la commande ./meteo.sh avec les options choisies

Listes des options : 

-f <fichier.csv> : permet d’indiquer au programme le fichier contenant les données (OBLIGATOIRE)

-t1 (ou -p1) : produit   en   sortie   les   températures   (ou   pressions) minimales, maximales et moyennes par station dans l’ordre croissant du numéro de station.
-t2 (ou -p2) : produit   en   sortie   les   températures   (ou   pressions) moyennes par date/heure, triées dans l’ordre chronologique. La moyenne se fait sur toutes les stations.
-t3 (ou -p3) : produit   en   sortie   les   températures   (ou   pressions)   par date/heure par station. 
-w : produit en sortie l’orientation moyenne et la vitesse moyenne des
vents pour chaque station.
-h : produit en sortie l’altitude pour chaque station.
-m : Produit en sortie l’humidité maximale par station.

-d <datemin> <datemax> : limite les données triées dans l’intervalle de date [datemin;datemax] (format : YYYY-MM-DD)

-A : restriction géographique (Antilles)
-Q : restriction géographique (Antarctique)
-F : restriction géographique (France métropolitaine+Corse)
-S : restriction géographique (Saint-Pierre-Et-Miquelon)
-G : restriction géographique (Guyane)
-O : restriction géographique (Océan Indien)


Restrictions techniques du programme : 

Le programme C n’est pas modulé à cause de bugs sur les commandes “include” des différents fichiers C. 
Le script shell n’arrive pas à appeler l’exécutable C, et donc le tri du C n’est pas effectué.
Le programme shell n’effectue pas le GnuPlot approprié car les données ne sont pas triés.
Le programme C ne peut pas trier avec les tableaux.

