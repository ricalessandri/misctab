#!/bin/bash 

####################################################################
# PARAMETERS WHICH MAY BE CHANGED
n_mol_A=8000       # number to be fed to gmx insert-molecules 
n_mol_B=8000       # number to be fed to gmx insert-molecules  
no_steps=5000000   # 100 ns
lblt=100ns
lblFF=m30420
####################################################################


####################################################################
# Check input
mol_A="$1"; beads_A="$2"; mol_B="$3"; beads_B="$4"; temp="$5"
size_1=${#mol_A}; size_2=${#beads_A}; size_3=${#mol_B}; size_4=${#beads_B}; size_5=${#temp}
if [ $size_1 -eq 0 -o $size_2 -eq 0 -o $size_3 -eq 0 -o $size_4 -eq 0 -o $size_5 -eq 0 ] ; then
   echo ""
   echo "The script needs the names of the two molecules which make up the mixtures and the temperature. E.g.:"
   echo " ./run_misctab_GMX16_cartes.sh  CLBZ   3     THF   2     293.15 "
   exit
fi

# Check if A or B are either water (W) or methanol (MEO) and adjust number of beads accordingly
if   [ ${mol_A} == "W" ]; then n_mol_A=2000; elif [ ${mol_A} == "MEO" ]; then n_mol_A=4000; fi
if   [ ${mol_B} == "W" ]; then n_mol_B=2000; elif [ ${mol_B} == "MEO" ]; then n_mol_B=4000; fi

# Create folder and submit the job
mkdir -p 5050-${mol_A}-${mol_B}-${lblFF}-T${temp}-${lblt}
cp template-miscibility/*  5050-${mol_A}-${mol_B}-${lblFF}-T${temp}-${lblt}/.
cd       5050-${mol_A}-${mol_B}-${lblFF}-T${temp}-${lblt}
sed -i "s/--job-name=MIXTURE/--job-name=${mol_A}${mol_B}/" setup_and_run_mixture.sh
sed -i "s/--output=MIXTURE/--output=${mol_A}${mol_B}/"     setup_and_run_mixture.sh
chmod u+x setup_and_run_mixture.sh
sbatch setup_and_run_mixture.sh ${mol_A} ${beads_A} ${mol_B} ${beads_B} ${n_mol_A} ${n_mol_B} ${temp} ${no_steps}

