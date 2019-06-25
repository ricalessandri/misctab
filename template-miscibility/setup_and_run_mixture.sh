#!/bin/bash

#### Jobname and output file
#SBATCH --job-name=MIXTURE
#SBATCH --output=MIXTURE.%J.out
#### Choice for partions CARTESIUS:
#SBATCH --partition=normal
#SBATCH --partition=short
#####SBATCH --partition=broadwell_short
#SBATCH --ntasks=16
#### Time of simulation
#SBATCH --time=12:00:00
#SBATCH --time=01:00:00

########################################################
################          GMX         ##################
module purge                # Cartesius
module load gromacs/2016.3  # Cartesius
module list                 # Cartesius

FLAGS='-dlb yes -rdd 1.4'

# SET GMX COMMAND aliases 
INSMOL="srun -n  1 gmx_mpi insert-molecules" # Cartesius
GROMPP="srun -n 1 gmx_mpi grompp"            # Cartesius
MDRUN="srun gmx_mpi mdrun"                   # Cartesius
MDRUN8="srun -n 8 gmx_mpi mdrun"             # Cartesius
########################################################


# 0. Molecule info (coming from previous script)
mol_A="$1"; beads_A="$2"; mol_B="$3"; beads_B="$4"; n_mol_A="$5"; n_mol_B="$6"; temp="$7"; no_steps="$8"


# 1. Use an already existing solvent box (if found) or create one:
if test -f ${beads_A}bead${beads_B}bead-${n_mol_A}${n_mol_B}.gro; then
   cp ${beads_A}bead${beads_B}bead-${n_mol_A}${n_mol_B}.gro   0-start.gro
else
   ${INSMOL} -ci ${beads_A}bead_molecule.gro -nmol ${n_mol_A} -box 9.5 9.5 200.0 -o 0-mol_A.gro -radius 0.28 -scale 1.0 # WORKS in most cases
   ${INSMOL} -ci ${beads_B}bead_molecule.gro -nmol ${n_mol_B} -f 0-mol_A.gro     -o 0-start.gro -radius 0.28 -scale 1.0 -try 200
fi


# 2. Prepare TOP file 
cp system_EMPTY.top system.top
echo ${mol_A}  "   $n_mol_A " >> system.top
echo ${mol_B}  "   $n_mol_B " >> system.top

# 3. Energy minimization
${GROMPP} -p system.top -c 0-start.gro -f min-mix.mdp -o 1-min -po 1-min -maxwarn 1
$MDRUN8 $FLAGS -deffnm 1-min

# 4. NPT at 30 bar (lateral dimensions fixed)
sed -i "s/TEMPE/${temp}/" squeeze-mix-semiisoNPT.mdp
${GROMPP} -p system.top -c 1-min.gro   -f squeeze-mix-semiisoNPT.mdp -o 2-squeeze -po 2-squeeze -maxwarn 1
$MDRUN8 $FLAGS -deffnm 2-squeeze

# 5. NPT at  1 bar (lateral dimensions fixed)
sed -i "s/TEMPE/${temp}/"             md-mix-semiisoNPT.mdp
sed -i "s/NUMBEROFSTEPS/${no_steps}/" md-mix-semiisoNPT.mdp
${GROMPP} -p system.top -c 2-squeeze.gro -f md-mix-semiisoNPT.mdp    -o 3-mix -po 3-mix -maxwarn 1
$MDRUN $FLAGS -deffnm 3-mix


