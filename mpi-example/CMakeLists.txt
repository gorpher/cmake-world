find_package(MPI REQUIRED)

add_executable(mpi-example mpi-example.cpp)
target_link_libraries(mpi-example
        PUBLIC
        MPI::MPI_CXX
        )

# 并行运行： mpirun -np 2 ./mpi-example