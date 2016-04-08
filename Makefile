FC = mpif90
FLAGS = -O3 -I./obj

INC = -I${TACC_NETCDF_INC}/
LIB = -L${TACC_NETCDF_LIB}/ -L${TACC_HDF5_LIB}/ -lnetcdff -lhdf5_hl -lhdf5 -lz

FLAGS += ${INC}
LDFLAGS = ${FLAGS} ${LIB}

FD = obj/

EXE = Compute_Rainrate

main = $(EXE).o
modules = $(FD)module_core.o $(FD)module_mpi.o $(FD)module_particle.o

$(EXE): $(FD)$(main) $(modules)
	$(FC) $(FLAGS) -o $(EXE) $(FD)$(main) $(modules) $(LDFLAGS)

$(FD)$(main): $(EXE).F90 $(modules)
	$(FC) $(FLAGS) -c $(EXE).F90
	mv $(EXE).o $(FD)

#modules
$(FD)module_mpi.o: module_mpi.F90
	$(FC) $(FLAGS) -c module_mpi.F90
	mv module_mpi.o $(FD); mv mpi_info.mod $(FD)

$(FD)module_particle.o: module_particle.F90 module_mpi.F90
	$(FC) $(FLAGS) -c module_particle.F90
	mv module_particle.o $(FD); mv particle_data.mod $(FD)

$(FD)module_core.o: module_core.F90 $(FD)module_mpi.o $(FD)module_particle.o
	$(FC) $(FLAGS) -c module_core.F90
	mv module_core.o $(FD); mv core_info.mod $(FD)

clean:
	rm -f $(FD)*.o
cleanmod:
	rm -f $(FD)*.mod
cleanall:
	rm -f $(FD)*.o; rm -f $(FD)*.mod; rm -f $(EXE)
