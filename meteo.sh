#!/bin/bash

rm ftrie/*.txt 2>/dev/null
rm fnontrie/*.txt 2>/dev/null

#--------------------------------------------------------------------------------------------------
#--------------------------------------- Fonctions shell ------------------------------------------
#--------------------------------------------------------------------------------------------------

#!/bin/bash

moyenne() {
    tot=0
    for arg in "$@" ; do
        tot+=$arg
    done
    moy=$(( tot / $# ))
    return $moy
}

min() {
    min=$1
    for arg in "$@" ; do
        if (( arg < min )) ; then
            min=$arg
        fi
    done
    return "$min"
}

max() {
    max=$1
    for arg in "$@" ; do
        if (( arg > max )) ; then
            max=$arg
        fi
    done
    return "$max"
}

loctest() {
    if [[ $1 == *.csv ]] ; then

        if [ "$2" -eq 1 ] ; then
            awk -F'[;,]' '+$10 > 36 && +$10 < 55 && +$11 < 15 && +$11 > -8 {print $0}' 
            $1 > fnontrie/nontrieloc.txt # France 
        fi
        if [ "$2" -eq 3 ] ; then
            awk -F'[;,]' '+$10 > 46 && +$10 < 48 && +$11 < -54 && +$11 > -58 {print $0}' 
            $1 > fnontrie/nontrieloc.txt # Canada 
        fi
        if [ "$2" -eq 6 ] ; then
            awk -F'[;,]' '+$10 > 46 && +$10 < 48 && +$11 < -54 && +$11 > -58 {print $0}' 
            $1 > fnontrie/nontrieloc.txt # Antarctique 
        fi
        if [ "$2" -eq 2 ] ; then
            awk -F'[;,]' '+$10 > 1 && +$10 < 7 && +$11 < -50 && +$11 > -56 {print $0}' 
            $1 > fnontrie/nontrieloc.txt # Guyane
        fi
        if [ "$2" -eq 4 ] ; then
            awk -F'[;,]' '+$10 > 9 && +$10 < 20 && +$11 < -56 && +$11 > -72 {print $0}' 
            $1 > fnontrie/nontrieloc.txt # Antilles 
        fi
        if [ "$2" -eq 5 ] ; then
            awk -F'[;,]' '+$10 < -53 {print $0}' 
            $1 > fnontrie/nontrieloc.txt # Océan Indien 
        fi
    else
        echo 'Option invalide : loctest nécéssite un .csv.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
    fi
}

datetest() {
    if [[ $1 == *.csv ]] ; then
        awk -F'[;,]' -v dmin="$2" dmax="$3" '
            t=gensub(/[-T:]/," ","g",$2)
            tnouv=substr(t,0,13)
            timestamp=mktime(tnouv " 00 00")
            if (dmin<timestampdata && dmax>timestampdata) {print $0 ";" timestamp}
            ' "$1" > fnontrie/datenontrie.txt
    else
        echo 'Option invalide : datetest nécéssite un .csv.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
    fi
}


#--------------------------------------------------------------------------------------------------
#------------------------------ Récupération et vérification des options --------------------------
#--------------------------------------------------------------------------------------------------

for arg in "$@" ; do                             #Parcours des options pour vérifier leur validité et les adapter si besoin
    shift
    case $arg in
        "--avl") set -- "$@" '-a' ;;                   #Transformation des options longues en simple (utilitaire getopts)
        "--abr") set -- "$@" '-b' ;;
        "--tab") set -- "$@" '-T' ;;
        "--help") set -- "$@" '-l' ;;
        "-f"*) if [ -z "$fut" ] ; then             #Vérifie que -f n'est appelé qu'une fois
            set -- "$@" "$arg"
            fut=1
        else
            echo "Erreur de paramètre : -f ne peut être appelé qu'une fois."
            exit
        fi ;;
        "-d"*) if [ -z "$dut" ] ; then                  #Vérifie que -d n'est appelé qu'une fois
            set -- "$@" "$arg"
            dut=1
        else
            echo "Erreur de paramètre : -d ne peut être appelé qu'une fois."
            exit
        fi ;;
        "-"[pt]) echo "Erreur de mode : Les options -p et -t ont besoin d'un mode (1, 2 ou 3)."
        exit
        ;;
        -[FGSAOQwhmr]) set -- "$@" "$arg" ;;             #Vérifie la validité des options simples
        -[pt][123]) set -- "$@" "$arg" ;;               #Ne laisse passer que les modes 1, 2 et 3 de -t et -p
        ????-??-??) set -- "$@" "$arg" ;;               #Laisse passer les dates au bon format
        *".csv") if [ -z "$csvut" ]; then              #Eviter qu'un unique fichier csv est passé en paramètres.
            set -- "$@" "$arg" 
            csvut=1
        else
            echo "Erreur de paramètre : deux fichiers .csv ont été identifiés, alors qu'un seul est nécessaire (après l'option -f)."
            exit
        fi ;;
        *) echo "Erreur de lancement : <$arg> paramètre inconnu." 
        exit 
        ;;
    esac
done


while getopts ':FGSAOQt:p:whmrf:d:abTl' OPTION; do          #Utilitaire getopts pour simplifier le traitement d'options
    case "$OPTION" in
        F) if [ -z "$ArgLoc" ] ; then           #Attribue une valeur à la localisation, et arrête le programme...
                ArgLoc=1                        #... si l'utilisateur a passé plusieurs options de localisation 
            else
                echo 'Option invalide : Un seul appel de restriction géographique est autorisé.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null   #Supprime les fichiers temporaires (idem avant tous les exit)
                exit
            fi
            ;;
        G) if [ -z "$ArgLoc" ] ; then
                ArgLoc=2
            else
                echo 'Option invalide : Un seul appel de restriction géographique est autorisé.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;
        S) if [ -z "$ArgLoc" ] ; then
                ArgLoc=3
            else
                echo 'Option invalide : Un seul appel de restriction géographique est autorisé.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;
        A) if [ -z "$ArgLoc" ] ; then
                ArgLoc=4
            else
                echo 'Option invalide : Un seul appel de restriction géographique est autorisé.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;
        O) if [ -z "$ArgLoc" ] ; then
                ArgLoc=5
            else
                echo 'Option invalide : Un seul appel de restriction géographique est autorisé.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;
        Q) if [ -z "$ArgLoc" ] ; then
                ArgLoc=6
            else
                echo 'Option invalide : Un seul appel de restriction géographique est autorisé.'
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;
        
        t) if [ "$OPTARG" = "1" ] ; then                #Crée deux fichiers txt correspondants aux fichiers temporaires...
                touch ftrie/t1s.txt                  #... triés et non-triés (trié en C) en fonction de l'option.
                touch fnontrie/t1ns.txt
            elif [ "$OPTARG" = "2" ] ; then
                touch ftrie/t2s.txt
                touch fnontrie/t2ns.txt
            elif [ "$OPTARG" = "3" ] ; then
                touch ftrie/t3s.txt
                touch fnontrie/t3ns.txt
                touch fnontrie/t3nsf.txt
                touch ftrie/t3sf.txt
            else
                echo "Problème de mode : le mode $OPTARG n'existe pas pour la température."
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;

        p) if [ "$OPTARG" = "1" ] ; then
                touch ftrie/p1s.txt
                touch fnontrie/p1ns.txt
                touch ftrie/p1sf.txt
                touch fnontrie/p1nsf.txt
            elif [ "$OPTARG" = "2" ] ; then
                touch ftrie/p2s.txt
                touch fnontrie/p2ns.txt
            elif [ "$OPTARG" = "3" ] ; then
                touch ftrie/p3s.txt
                touch fnontrie/p3ns.txt
                touch ftrie/p3sf.txt
                touch fnontrie/p3nsf.txt
            else
                echo "Problème de mode : le mode $OPTARG n'existe pas pour la pression."
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi
            ;;

        w) touch ftrie/ws.txt
        touch fnontrie/wns.txt ;;
        h) touch ftrie/hs.txt
        touch fnontrie/hns.txt ;;
        m) touch ftrie/ms.txt
        touch fnontrie/mns.txt ;;

        f) if [ -n "$OPTARG" ] ; then
            if [ "${OPTARG##*.}" = "csv" ]; then        #Récupère le fichier en vérifiant son format.
                file=$OPTARG
            else
                echo "Erreur de paramètre : l'option -f doit être suivie d'un fichier au format csv."
                rm ftrie/*.txt 2>/dev/null
                rm fnontrie/*.txt 2>/dev/null
                exit
            fi 
        else
            echo "Erreur de paramètre : l'option -f doit être suivie du fichier .csv contenant les données."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi
        ;;
        
        a) if [ -z "${typetri}" ] ; then       #Vérifie si le mode de tri n'est pas déjà attribué (option exclusive).
            typetri=1
        else
            echo 'Option invalide : Un seul appel de restriction de tri est autorisée.'
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi ;;
        b) 
        if [ -z "${typetri}" ] ; then
            typetri=2
        else
            echo 'Option invalide : Un seul appel de restriction de tri est autorisée.'
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi ;;
        T) if [ -z "${typetri}" ] ; then
            typetri=3
        else
            echo 'Option invalide : Un seul appel de restriction de tri est autorisée.'
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi ;;
        
        d) dmin=$OPTARG             #Récupère la date minimum et saute la date maximum qui sera récupérée plus tard 
        tmp=$((OPTIND-1))          #(son emplacement est enregistré dans tmp)
        OPTIND="$((OPTIND+1))"     #En effet, getopts ne prend en compte que les options avec un unique paramètre
        dut=1
        ;;

        r) reverse="-r";;
        
        l) printf "Utilisation meteo.sh : \nEn fonction des options passés en paramètres,
        trie le fichier csv appelé avec -f, et les affiche avec l'utilitaire GnuPlot.\n\n
        Options :
            -f <fichier.csv> (OBLIGATOIRE) : utilisée pour récupérer le fichier csv à trier\n
            -t<mode> / p<mode> : trie la température/pression selon le mode 
            (1 : produit   en   sortie   les   températures   (ou   pressions) minimales, 
            maximales et moyennes par station dans l’ordrecroissant du numéro de station; 2 : 
            produit   en   sortie   les   températures   (ou   pressions) moyennes par date/heure, 
            triées dans l’ordre chronologique ; 3 : 
            produit   en   sortie   les   températures   (ou   pressions)   
            par date/heure par station. )\n
            -w : produit en sortie l’orientation moyenne et la vitesse moyenne des vents pour chaque station.\n
            -m : Produit   en   sortie   l’humidité   maximale   pour   chaque   station.\n
            -h : Produit en sortie l’altitude pour chaque station.
            -d <dmin> <dmax> : ne trie que les données entre dmin et dmax\n
            -A : restriction géographique (Antilles)\n
            -F : restriction géographique (France métropolitaine + Corse)\n
            -G : restriction géographique (Guyane française)\n
            -Q : restriction géographique (Antarctique)\n
            -O : restriction géographique (Océan Indien)\n
            -S : restriction géographique (Saint-Pierre-Et-Miquelon)\n
            --tab : trie avec des tableaux\n
            --abr : trie avec les ABR\n
            --avl : trie avec les AVL\n
            "
            ;;

        *) echo 'Option inconnue'
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
            ;;

    esac
done


shift ${tmp}
dmax="$1"           #Récupération de la date max, ramenée en premier argument avec la commande shift 


if [ -z "$dut" ] && [[ "$dmax" = ????-??-?? ]]; then     #Vérifie le format de la date max et son emplacement
    echo "Erreur de paramètre : une ou plusieurs dates ont été mises en paramètre sans l'option -d."
    rm ftrie/*.txt 2>/dev/null
    rm fnontrie/*.txt 2>/dev/null
    exit
fi

if [ -z "${typetri}" ] ; then      #Cas par défaut du tri : AVL
    typetri=1
fi

if [ -z "${file}" ] ; then      #Vérifie la présence du fichier csv
    echo "Erreur de paramètre : Un fichier csv doit être fourni avec l'option -f (format : -f <nom_fichier> )."
    rm ftrie/*.txt 2>/dev/null
    rm fnontrie/*.txt 2>/dev/null
    exit
fi


if [ -n "$dmin" ] ; then        #Si dmin a bien été attribué, alors on vérifie le format de la date min et max, et on convertis en timestamp (secondes depuis 1970).
    if [[ $dmin =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$dmin" >/dev/null 2>&1 ; then
        dmins=$(date -d "$dmin" +%s)
    else
        echo "Erreur de paramètre : l'option -d doit être suivie de la date minimum puis maximum (date réelle), au format YYYY-MM-DD."
        rm ftrie/*.txt 2>/dev/null
        rm fnontrie/*.txt 2>/dev/null
        exit
    fi

    if [[ $dmax =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$dmax" >/dev/null 2>&1 ; then
        dmaxs=$(date -d "$dmax" +%s)
    else
        echo "Erreur de paramètre : l'option -d doit être suivie de la date minimum puis maximum (date réelle), au format YYYY-MM-DD."
        rm ftrie/*.txt 2>/dev/null
        rm fnontrie/*.txt 2>/dev/null
        exit
    fi

    if (( dmins > dmaxs )) ; then         #On vérifie que les dates sont passées dans le bon ordre
        echo "Erreur de paramètres : la première date passée en paramètres à -d doit être plus petite que la seconde (format : -d <datemin> <datemax> )."
        rm ftrie/*.txt 2>/dev/null
        rm fnontrie/*.txt 2>/dev/null
        exit
    fi
fi



make
chmod 777 triexec

#--------------------------------------------------------------------------------------------------
#------------------------------ Ecriture dans les fichiers temporaires ----------------------------
#--------------------------------------------------------------------------------------------------


if [ -n "$dmin" ] && [ -n "$ArgLoc" ]; then       #Si -d et une restriction géograpghique ont été appelées, on utilise une boucle qui dépend de la date et du lieu

    loctest "$file $ArgLoc"                 #On fait les vérif de localisation d'abord puis la date en supprimant la ligne 1
    sed -i "1d" fnontrie/nontrieloc.txt
    datetest "$file $dmins $dmaxs"

    if [ -e ftrie/t1s.txt ] ; then       #On écrit dans le fichier temporaire non-trié relatif aux options appelées
        awk -F'[;,]' '{
            length($13) == 0 || length($14) == 0 { print $1 ";" $12 ";" $12 ";" $12 }
        }' fnontrie/datenontrie.txt >fnontrie/t1ns.txt 
        awk -F'[;,]' '{
            length($13) > 0 && length($14) > 0 { print $1 ";" $13 ";" $14 ";" $12 }
        }' fnontrie/datenontrie.txt >>fnontrie/t1ns.txt
    fi


    if [ -e ftrie/t2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt >fnontrie/t2ns.txt
    fi


    if [ -e ftrie/t3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt > fnontrie/t3ns.txt
    fi


    if [ -e ftrie/p1s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p1ns.txt
    fi


    if [ -e ftrie/p2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p2ns.txt
    fi


    if [ -e ftrie/p3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p3ns.txt
    fi


    if [ -e ftrie/hs.txt ] ; then
        awk -F'[;,]' '{print $15 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/hns.txt
    fi


    if [ -e ftrie/ms.txt ] ; then
        awk -F'[;,]' '{print $6 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/mns.txt
    fi


    if [ -e ftrie/ws.txt ] ; then
        awk -F'[;,]' '{print $1 ";" $4 ";" $5 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/wns.txt  
    fi



elif [ -z "$dmin" ] && [ -n "$Argloc" ]; then       #Même système que précédemment mais sans la vérif du temps

    loctest "$file $ArgLoc"                 #On vérifie juste la localisation
    sed -i "1d" fnontrie/nontrieloc.txt

    awk -F'[;,]' '{
            t=gensub(/[-T:]/," ","g",$2)
            tnouv=substr(t,0,13)
            timestamp=mktime(tnouv " 00 00")
            print $0 ";" timestamp
            }' fnontrie/nontrieloc.txt > fnontrie/datenontrie.txt     #Sans vérif de la date, on ajoute manuellement le timestamp à la fin de chaque ligne
    

    if [ -e ftrie/t1s.txt ] ; then       #On écrit dans le fichier temporaire non-trié relatif aux options appelées
        awk -F'[;,]' '{
            length($13) == 0 || length($14) == 0 { print $1 ";" $12 ";" $12 ";" $12 } }
        ' fnontrie/datenontrie.txt >fnontrie/t1ns.txt 
        awk -F'[;,]' '{
            length($13) > 0 && length($14) > 0 { print $1 ";" $13 ";" $14 ";" $12 } }
        ' fnontrie/datenontrie.txt >>fnontrie/t1ns.txt
    fi


    if [ -e ftrie/t2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt >fnontrie/t2ns.txt
    fi


    if [ -e ftrie/t3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt > fnontrie/t3ns.txt
    fi


    if [ -e ftrie/p1s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3
        ' fnontrie/datenontrie.txt > fnontrie/p1ns.txt
    fi


    if [ -e ftrie/p2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p2ns.txt
    fi


    if [ -e ftrie/p3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p3ns.txt
    fi


    if [ -e ftrie/hs.txt ] ; then
        awk -F'[;,]' '{print $15 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/hns.txt
    fi


    if [ -e ftrie/ms.txt ] ; then
        awk -F'[;,]' '{print $6 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/mns.txt
    fi


    if [ -e ftrie/ws.txt ] ; then
        awk -F'[;,]' '{print $1 ";" $4 ";" $5 ";" $13 ";" $14
        ' fnontrie/datenontrie.txt > fnontrie/wns.txt  
    fi

elif [ -n "$dmin" ] && [ -z "$Argloc" ]; then        #Même système que précédemment mais sans la vérif géographique

    datetest "$file $dmins $dmaxs" 
    sed -i "1d" fnontrie/datenontrie.txt
    

    if [ -e ftrie/t1s.txt ] ; then       #On écrit dans le fichier temporaire non-trié relatif aux options appelées
        awk -F'[;,]' '{
            length($13) == 0 || length($14) == 0 { print $1 ";" $12 ";" $12 ";" $12 } }
        ' fnontrie/datenontrie.txt >fnontrie/t1ns.txt 
        awk -F'[;,]' '{
            length($13) > 0 && length($14) > 0 { print $1 ";" $13 ";" $14 ";" $12 } }
        ' fnontrie/datenontrie.txt >>fnontrie/t1ns.txt
    fi


    if [ -e ftrie/t2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt >fnontrie/t2ns.txt
    fi


    if [ -e ftrie/t3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt > fnontrie/t3ns.txt
    fi


    if [ -e ftrie/p1s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p1ns.txt
    fi


    if [ -e ftrie/p2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p2ns.txt
    fi


    if [ -e ftrie/p3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p3ns.txt
    fi


    if [ -e ftrie/hs.txt ] ; then
        awk -F'[;,]' '{print $15 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/hns.txt
    fi


    if [ -e ftrie/ms.txt ] ; then
        awk -F'[;,]' '{print $6 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/mns.txt
    fi


    if [ -e ftrie/ws.txt ] ; then
        awk -F'[;,]' '{print $1 ";" $4 ";" $5 ";" $13 ";" $14
        ' fnontrie/datenontrie.txt > fnontrie/wns.txt  
    fi
        

else                #Même système que précédemment mais sans vérification


    sed "1d" "$file" >fnontrie/wflns.txt         #Pour ne pas supprimer la première ligne du csv, on le copie dans un autre fichier sans cette ligne
    awk -F'[;,]' '{
            time=gensub(/[-T:]/," ","g",$2)
            timenew=substr(time,0,13)                   
            timestampdata=mktime(timenew " 00 00")
            print $0 ";" timestampdata
            }' fnontrie/wflns.txt > fnontrie/datenontrie.txt       #On appelle pas la date donc on rajoute manuellement le timestamp pour chaque ligne
    

    if [ -e ftrie/t1s.txt ] ; then       #On écrit dans le fichier temporaire non-trié relatif aux options appelées
        awk -F'[;,]' '{
            length($13) == 0 || length($14) == 0 { print $1 ";" $12 ";" $12 ";" $12 } }
        ' fnontrie/datenontrie.txt >fnontrie/t1ns.txt 
        awk -F'[;,]' '{
            length($13) > 0 && length($14) > 0 { print $1 ";" $13 ";" $14 ";" $12 } }
        ' fnontrie/datenontrie.txt >>fnontrie/t1ns.txt
    fi


    if [ -e ftrie/t2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt >fnontrie/t2ns.txt
    fi


    if [ -e ftrie/t3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $12 }
        ' fnontrie/datenontrie.txt > fnontrie/t3ns.txt
    fi


    if [ -e ftrie/p1s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p1ns.txt
    fi


    if [ -e ftrie/p2s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p2ns.txt
    fi


    if [ -e ftrie/p3s.txt ] ; then
        awk -F'[;,]' '{print $17 ";" $2 ";" $1 ";" $3 }
        ' fnontrie/datenontrie.txt > fnontrie/p3ns.txt
    fi


    if [ -e ftrie/hs.txt ] ; then
        awk -F'[;,]' '{print $15 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/hns.txt
    fi


    if [ -e ftrie/ms.txt ] ; then
        awk -F'[;,]' '{print $6 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/mns.txt
    fi


    if [ -e ftrie/ws.txt ] ; then
        awk -F'[;,]' '{print $1 ";" $4 ";" $5 ";" $13 ";" $14 }
        ' fnontrie/datenontrie.txt > fnontrie/wns.txt  
    fi


fi


#--------------------------------------------------------------------------------------------------
#------------------------------ Traitement en C et application sur GnuPlot ------------------------
#--------------------------------------------------------------------------------------------------

if (( typetri == 1 )) ; then 
    argtri="--avl"
elif (( typetri == 2 )) ; then         #Selon le type de sortie on écrit l'option dans une variable qu'on passera au C
    argtri="--abr"
elif (( typetri == 3 )) ; then
    argtri="--tab"
else
    echo "Erreur de tri : méthode de tri inconnue."
    rm ftrie/*.txt 2>/dev/null
    rm fnontrie/*.txt 2>/dev/null
    exit
fi


#A partir d'ici le même motif se répète : selon les modes appelés, on appelle le C, on vérifie la sortie
#et parfois on rappelle une deuxième fois le C pour un deuxième tri selon une autre variable
if [ -e ftrie/t1s.txt ] ; then                      
    if [ -s fnontrie/t1ns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/t1ns.txt -o ftrie/t1s.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        gnuplot_script=$(cat <<EOF
     set terminal png
     set datafile separator ";"
     set output "t1.png"
     set title "Temperature dans chaque station"
     set xlabel "Id de station"
     set ylabel "Température (en Celsius)"
     set key off
     plot "meteo_filtered_data_v1.csv" using 1:2:3:4 with yerrorbars title "Temperature"

EOF
)
echo "$gnuplot_script" | gnuplot
open "t1.png"


    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (température 1)."
    fi
fi


if [ -e ftrie/t2s.txt ] ; then
    if [ -s fnontrie/t2ns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/t2ns.txt -o ftrie/t2s.txt "$reverse"
        ressort=$?
        echo "$ressort"
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

gnuplot_script=$(cat <<EOF

# Set the title and axis labels
set terminal png
set datafile separator ";"
set title "La moyenne des températures en fonction de la date"
set xlabel "jour et heures"
set ylabel "moyenne des températures"
set output "t2.png"
set autoscale fix

# Plot the data
plot"meteo_filtered_data_v1.csv" using 2:4 with lines

EOF
)

echo "$gnuplot_script" | gnuplot
open "t2.png"

    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (température 2)."
    fi
fi


if [ -e ftrie/t3s.txt ] ; then
    if [ -s fnontrie/t3ns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/t3ns.txt -o ftrie/t3s.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        awk -F'[;,]' '{print $3 ";" $2 ";" $1 ";" $4 }
        ' ftrie/t3s.txt > ftrie/t3nsf.txt         #On trie de nouveau mais selon une autre variable

        ./triexec "$argtri" -f fnontrie/t3nsf.txt -o ftrie/p3sf.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        gnuplot_script=$(cat <<EOF

# Set the title and axis labels
set terminal png
set datafile separator ";"
set title "température"
set xlabel "jour et heure de la mesure"
set ylabel "ID de la station"
set output "t3.png"
set autoscale fix

# Plot the data
plot "t3.png" using 1:2:3:4 with errorbars

EOF
)

echo "$gnuplot_script" | gnuplot
open "t3.png"


    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (température 3)."
    fi
fi


if [ -e ftrie/p1s.txt ] ; then
    if [ -s fnontrie/p1ns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/p1ns.txt -o ftrie/p1s.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        awk -F'[;,]' '{print $3 ";" $1 ";" $2 ";" $4 }
        ' ftrie/p1s.txt > fnontrie/p1nsf.txt


        ./triexec "$argtri" -f fnontrie/p1nsf.txt -o ftrie/p1sf.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        touch ftrie/p1fin.txt                    #On calcule la moyenne, le minimum et le maximum de pression par jour pour chaque station
        while IFS=";," read -r ID dsrealfile datec prm ; do
            date=${datec:0:10}
            if [ "$datec" -ne "$datechg" ] ; then       #On récupère la date à chaque ligne, et on vérifie qu'elle a changé
                minch=$(min "$ch")                      #Si elle a effectivement changé, on calcule la moyenne, min et max 
                maxch=$(max "$ch")                      #pour une station pendant un jour, qu'on enregistre dans un nouveau fichier
                moych=$(moy "$ch")
                echo "${lastID};${minch};${maxch};${moych}"
                ch=""
            fi
            ch="$prm $ch"       #On ajoute chaque donnée tant que le jour est le même
            lastID=$ID
            datechg=$date
        done <ftrie/p1sf.txt


        gnuplot_script=$(cat <<EOF

# Set the title and axis labels
set terminal png
set datafile separator ";"
set title "Pression min max et moyenne en fonction de l'ID de la station"
set xlabel "ID de la station"
set ylabel "pression min, max et moyenne"
set output "p1.png"
set autoscale fix

# Plot the data
plot "meteo_filtered_data_v1.csv" using ID:Max:Min:Moy with errorbars

EOF
)

echo "$gnuplot_script" | gnuplot
open "p1.png"


    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (pression 1)."
    fi
fi


if [ -e ftrie/p2s.txt ] ; then
    if [ -s fnontrie/p2ns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/p2ns.txt -o ftrie/p2s.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

gnuplot_script=$(cat <<EOF

# Set the title and axis labels
set terminal png
set datafile separator ";"
set title "La moyenne des pressions en fonction de la date"
set xlabel "jour et heures"
set ylabel "moyenne des pressions"
set output "p2.png"
set autoscale fix

# Plot the data
plot "meteo_filtered_data_v1.csv" using 1:2 with lines

EOF
)
    
echo "$gnuplot_script" | gnuplot
open "p2.png"

    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (pression 2)."
    fi
fi


if [ -e ftrie/p3s.txt ] ; then
    if [ -s fnontrie/p3ns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/p3ns.txt -o ftrie/p3s.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        awk -F'[;,]' '{print $3 ";" $2 ";" $1 ";" $4 }
        ' ftrie/p3s.txt > ftrie/p3nsf.txt

        ./triexec "$argtri" -f fnontrie/p3nsf.txt -o ftrie/p3sf.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi
        
        gnuplot_script=$(cat <<EOF
       set terminal png
       set datafile separator ";"
       set output "p3.png"
       set xlabel "Id de la station"
       set ylabel "Pression en pascal"
       set title "Pression moyenne /h de chaque station"
       set xdata time
       set timefmt "%Y-%m-%d"
       set format x "%Y-%m-%d"
       plot "p3.txt" using 3:1:2 with linespoints lc variable     
 
EOF
)
echo "$gnuplot_script" | gnuplot
open "p3.png"
} 

    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (pression 3)."
    fi
fi


if [ -e ftrie/hs.txt ] ; then
    if [ -s fnontrie/hns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/hns.txt -o ftrie/hs.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo $"Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        gnuplot_script=$(cat <<EOF

# Set the title and axis labels
set terminal png
set datafile separator ";"
set title "altitude"
set xlabel "longitude"
set ylabel "latitude"
set output "h.png"
set autoscale fix
set size ratio 1
set xrange[0:100]
set yrange[0:100]

set palette rgb 10, 12, 13
set tics nomirror 

# Plot the data
splot "meteo_filtered_data_v1.csv" using 1:2 with image

EOF
)
    
echo "$gnuplot_script" | gnuplot
open "h.png"

    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (altitude)."
    fi
fi


if [ -e ftrie/ms.txt ] ; then
    if [ -s fnontrie/mns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/mns.txt -o ftrie/ms.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        gnuplot_script=$(cat <<EOF

# Set the title and axis labels
set terminal png
set datafile separator ";"
set title "humidité"
set xlabel "longitude"
set ylabel "latitude"
set output "m.png"
set autoscale fix
set size ratio 1
set xrange[0:100]
set yrange[0:100]

set palette rgb 10, 12, 13
set tics nomirror 

# Plot the data
splot "meteo_filtered_data_v1.csv" using 1:2 with image

EOF
)
    
echo "$gnuplot_script" | gnuplot
open "m.png"

    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (humidité)."
    fi
fi

if [ -e ftrie/ws.txt ] ; then
    if [ -s fnontrie/wns.txt ] ; then
        ./triexec "$argtri" -f fnontrie/wns.txt -o ftrie/ws.txt "$reverse"
        ressort=$?
        if (( ressort == 1 )) ; then
            echo "Erreur d'options : option manquante ou incomplète à l'appel du fichier de tri."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort == 2 )) ; then
            echo "Erreur de fichier : impossible de traiter le fichier d'entrée passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        elif (( ressort  == 3 )) ; then
            echo "Erreur de fichier : imposssible de traiter le fichier de sortie passé en paramètres."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit 
        elif (( ressort == 4 )) ; then
            echo "Erreur inconnue."
            rm ftrie/*.txt 2>/dev/null
            rm fnontrie/*.txt 2>/dev/null
            exit
        fi

        touch ftrie/wsf.txt                              #Même système que pour -p1, mais cette fois pour la moyenne de vitesse et de direction du vent de chaque station
        while IFS=";," read -r ID dir vit lat long ; do             
            if [ "$lastID" -ne "$ID" ] ; then
                moyv=$(moy "$ch")
                moyd=$(moy "$ch2")
                echo "${lastID};${moyd};${moyv};${lat};${long}"
                ch=""
            fi
            ch="$vit $ch"
            ch2="$dir $ch2"
            lastID=$ID
        done <ftrie/ws.txt

        gnuplot_script=$(cat <<EOF
     set terminal png
     set datafile separator ";"
     set output "w.png"
     set title "Vecteur moyen de la direction du vent"
     set xlabel "Longitude"
     set ylabel "Latitude"
     set obj 1 fillstyle solid 1.0 fillcolor rgbcolor "blue"
     set key off
     set size square
     set object 1 rectangle from screen 0,0 to screen 1,1 behind
     set view map
     deg2rad(deg) = deg * pi / 180

    plot "w.txt" using 2:3:(sin(deg2rad(column(4)))*column(5)):(cos(deg2rad(column(4)))*column(5)) every 5 with vectors lc -1 filled notitle

EOF
)

echo "$gnuplot_script" | gnuplot
open "w.png"

    else 
        echo "Paramètres trop restrictifs : il n'existe aucune donnée dans le fichier correspondant aux options rentrées (vent)."
    fi
fi
