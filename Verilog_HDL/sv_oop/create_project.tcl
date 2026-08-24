# Vivado Project Generator

create_project sv_oop ./vivado

add_files ./src
add_files -fileset sim_1 ./tb
add_files -fileset constrs_1 ./constraints

update_compile_order -fileset sources_1

