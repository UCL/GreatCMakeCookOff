configure_file(${indir}/${testname}.cmake 
               ${outdir}/${testname}/CMakeLists.txt)
if(EXISTS ${outdir}/${testname}/build})
  file(REMOVE "${outdir}/${testname}/build}")
endif(EXISTS ${outdir}/${testname}/build})
file(MAKE_DIRECTORY ${outdir}/${testname}/build)
execute_process(COMMAND ${CMAKE_COMMAND} --cookoff_path=${cookoff_path} ${config_args} .. 
                WORKING_DIRECTORY ${outdir}/${testname}/build)

execute_process(COMMAND ${CMAKE_COMMAND} --build . ${build_args}
                WORKING_DIRECTORY ${outdir}/${testname}/build)
