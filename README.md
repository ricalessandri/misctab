#
# Setup and Run Binary Mixtures with Martini


You *NEED* the following (1 script and 1 folder):
```
 run_misctab_GMX16_cartes.sh
 template-miscibility/
```


*SUBMIT* a new mixture with:
```
 ./run_misctab_GMX16_cartes.sh  BENZ  3  CHEX  2  293.15
```
where the arguments correspond to:
*1)* "BENZ" -> label of molecule_A
*2)* "3"    -> no. of beads of molecule_A
*3)* "CHEX" -> label of molecule_B
*4)* "2"    -> no. of beads of molecule_B
*5)* 293.15 -> temperature


*NOTE* that the script uses a existing starting box named as:
```
 3bead2bead-80008000.gro
```
if available or creates one from scratch; the name contains the no. of beads per
molecule (3 beads for molecule_A, 2 beads for molecule_B) and the no. of molecules
per molecules (8000 for molecule_A, 8000 for molecule_B).
You can add yourself new pre-equilibrated starting boxes following the syntax
above to the folder "template-miscibility/".


*ADAPT* the script to run somewhere else than Cartesius:
1. Potentially need to modify the "sbatch" line in `./run_misctab_GMX16_cartes.sh`
2. Check the header of `template-miscibility/setup_and_run_mixture.sh`
which contains SBATCH commands such as:
`#SBATCH --partition=short` and command aliases such as:
`MDRUN="srun gmx_mpi mdrun"`.

