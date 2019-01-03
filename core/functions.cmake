# Add compile flags and defintions to the target
# according to the options selected by the user.
#
# Usage:
# ttk_set_compile_options(<library_name>)
#
function(ttk_set_compile_options library)
    target_compile_options(${library} PRIVATE -Wall)

    if(Boost_FOUND)
      target_link_libraries(${library} PUBLIC Boost::boost)
    endif()

    if(Boost_LIBRARIES)
      target_link_libraries(${library} PUBLIC Boost::system)
    endif()

    if (TTK_ENABLE_KAMIKAZE)
        target_compile_definitions(${library} PUBLIC TTK_ENABLE_KAMIKAZE)
    endif()

    if(NOT MSVC)
       if (TTK_ENABLE_CPU_OPTIMIZATION)
          target_compile_options(${library}
             PRIVATE $<$<CONFIG:Release>:-march=native -O3 -Wfatal-errors>)
       endif()

       target_compile_options(${library} PRIVATE $<$<CONFIG:Debug>:-O0 -g -pg>)
    endif()
    if(MSVC)
       # disable warnings
       target_compile_options(${library} PUBLIC /bigobj /wd4005 /wd4061 /wd4100 /wd4146 /wd4221 /wd4242 /wd4244 /wd4245 /wd4263 /wd4264 /wd4267 /wd4273 /wd4275 /wd4296 /wd4305 /wd4365 /wd4371 /wd4435 /wd4456 /wd4457 /wd4514 /wd4619 /wd4625 /wd4626 /wd4628 /wd4668 /wd4701 /wd4702 /wd4710 /wd4800 /wd4820 /wd4996 /wd5027 /wd5029 /wd5031)
    endif()

    if (TTK_ENABLE_OPENMP)
       if(NOT OpenMP_CXX_FOUND AND ${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.9")
          # executed once as openMP will either be found or deactivated
          find_package(OpenMP QUIET)
       endif()
       if(OpenMP_CXX_FOUND)
          target_compile_definitions(${library} PUBLIC TTK_ENABLE_OPENMP)
          target_compile_options(${library} PUBLIC ${OpenMP_CXX_FLAGS})
          target_link_libraries(${library} PUBLIC ${OpenMP_CXX_LIBRARIES})
       else()
          message(WARNING "OpenMP requested but not found, disabling: ${TTK_ENABLE_OPENMP}")
          set(TTK_ENABLE_OPENMP OFF CACHE BOOL "Enable OpenMP support" FORCE)
       endif()
    endif()

    if (TTK_ENABLE_MPI)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_MPI)
       target_include_directories(${library} PUBLIC ${MPI_CXX_INCLUDE_PATH})
       target_link_libraries(${library} PUBLIC ${MPI_CXX_LIBRARIES})
    endif()

    if (TTK_ENABLE_ZFP)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_ZFP)
       target_link_libraries(${library} PUBLIC zfp::zfp)
    endif()

    if(TTK_ENABLE_EIGEN)
      target_compile_definitions(${library} PUBLIC TTK_ENABLE_EIGEN)
      target_link_libraries(${library} PUBLIC Eigen3::Eigen)
    endif()

    if (TTK_ENABLE_ZLIB)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_ZLIB)
       target_include_directories(${library} PUBLIC ${ZLIB_INCLUDE_DIR})
       target_link_libraries(${library} PUBLIC ${ZLIB_LIBRARY})
    endif()

    if (TTK_ENABLE_GRAPHVIZ AND GRAPHVIZ_FOUND)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_GRAPHVIZ)
       target_include_directories(${library} PUBLIC ${GRAPHVIZ_INCLUDE_DIR})
       target_link_libraries(${library} PUBLIC ${GRAPHVIZ_CDT_LIBRARY})
       target_link_libraries(${library} PUBLIC ${GRAPHVIZ_GVC_LIBRARY})
       target_link_libraries(${library} PUBLIC ${GRAPHVIZ_CGRAPH_LIBRARY})
       target_link_libraries(${library} PUBLIC ${GRAPHVIZ_PATHPLAN_LIBRARY})
    endif()

    if (TTK_ENABLE_SCIKIT_LEARN)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_SCIKIT_LEARN)
    endif()

    if (TTK_ENABLE_SQLITE3)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_SQLITE3)
       target_include_directories(${library} PUBLIC ${SQLITE3_INCLUDE_DIR})
       target_link_libraries(${library} PUBLIC ${SQLITE3_LIBRARY})
    endif()

    if (TTK_ENABLE_64BIT_IDS)
       target_compile_definitions(${library} PUBLIC TTK_ENABLE_64BIT_IDS)
    endif()

 endfunction()


 # Used by basedCode requiring "Python.h"

 function(ttk_find_python)
    if (NOT PYTHONLIBS_FOUND)

       find_package(PythonLibs QUIET)

       if(PYTHONLIBS_FOUND)
          include_directories(${PYTHON_INCLUDE_DIRS})

          # find python version
          if(TTK_SUPERBUILD_BUILD)
             set(TTK_PYTHON_MAJOR_VERSION "${PYTHON_MAJOR_VERSION}"
                CACHE INTERNAL "TTK_PYTHON_MAJOR_VERSION")
             set(TTK_PYTHON_MINOR_VERSION "${PYTHON_MINOR_VERSION}"
                CACHE INTERNAL "TTK_PYTHON_MINOR_VERSION")
          else()
             string(REPLACE "." " "
                PYTHON_VERSION_LIST "${PYTHONLIBS_VERSION_STRING}")

             separate_arguments(PYTHON_VERSION_LIST)
             list(GET PYTHON_VERSION_LIST 0 PYTHON_MAJOR_VERSION)
             list(GET PYTHON_VERSION_LIST 1 PYTHON_MINOR_VERSION)

             set(TTK_PYTHON_MAJOR_VERSION "${PYTHON_MAJOR_VERSION}"
                CACHE INTERNAL "TTK_PYTHON_MAJOR_VERSION")
             set(TTK_PYTHON_MINOR_VERSION "${PYTHON_MINOR_VERSION}"
                CACHE INTERNAL "TTK_PYTHON_MINOR_VERSION")
          endif()

          if(TTK_PYTHON_MAJOR_VERSION)
             message(STATUS "Python version: ${TTK_PYTHON_MAJOR_VERSION}.${TTK_PYTHON_MINOR_VERSION}")
          else()
             message(STATUS "Python version: NOT-FOUND")
          endif()

          find_path(PYTHON_NUMPY_INCLUDE_DIR numpy/arrayobject.h PATHS
             ${PYTHON_INCLUDE_DIRS}
             /usr/lib/python${PYTHON_MAJOR_VERSION}.${PYTHON_MINOR_VERSION}/site-packages/numpy/core/include/
             /usr/local/lib/python${PYTHON_MAJOR_VERSION}.${PYTHON_MINOR_VERSION}/site-packages/numpy/core/include)
          if(PYTHON_NUMPY_INCLUDE_DIR)
             message(STATUS "Numpy headers: ${PYTHON_NUMPY_INCLUDE_DIR}")
             include_directories(${PYTHON_NUMPY_INCLUDE_DIR})
          else()
             message(STATUS "Numpy headers: NOT-FOUND")
          endif()
       endif()
    endif()

    if(PYTHON_NUMPY_INCLUDE_DIR)
       option(TTK_ENABLE_SCIKIT_LEARN "Enable scikit-learn support" ON)
    else()
       option(TTK_ENABLE_SCIKIT_LEARN "Enable scikit-learn support" OFF)
       message(STATUS
          "Improper python/numpy setup. Disabling sckikit-learn support in TTK.")
    endif()

 endfunction()

 # starting at CMake 3.12, use the Python module system

 # function(ttk_find_python)
 #    if (NOT Python_LIBRARIES)

 #       find_package(Python COMPONENTS Development)

 #       if(Python_INCLUDE_DIRS)
 #          include_directories(${Python_INCLUDE_DIRS})

 #          set(TTK_PYTHON_MAJOR_VERSION "${Python_VERSION_MAJOR}"
 #             CACHE INTERNAL "TTK_PYTHON_MAJOR_VERSION")
 #          set(TTK_PYTHON_MINOR_VERSION "${Python_VERSION_MINOR}"
 #             CACHE INTERNAL "TTK_PYTHON_MINOR_VERSION")

 #          if(TTK_PYTHON_MAJOR_VERSION)
 #             message(STATUS "Python version: ${TTK_PYTHON_MAJOR_VERSION}.${TTK_PYTHON_MINOR_VERSION}")
 #          else()
 #             message(STATUS "Python version: NOT-FOUND")
 #          endif()

 #          find_path(Python_NUMPY_INCLUDE_DIR numpy/arrayobject.h PATHS
 #             ${Python_INCLUDE_DIRS}
 #             /usr/lib/python${TTK_PYTHON_MAJOR_VERSION}.${TTK_PYTHON_MINOR_VERSION}/site-packages/numpy/core/include/
 #             /usr/local/lib/python${TTK_PYTHON_MAJOR_VERSION}.${TTK_PYTHON_MINOR_VERSION}/site-packages/numpy/core/include)
 #          if(Python_NUMPY_INCLUDE_DIR)
 #             message(STATUS "Numpy headers: ${Python_NUMPY_INCLUDE_DIR}")
 #             include_directories(${Python_NUMPY_INCLUDE_DIR})
 #          else()
 #             message(STATUS "Numpy headers: NOT-FOUND")
 #          endif()
 #       endif()
 #    endif()

 #    if(Python_NUMPY_INCLUDE_DIR)
 #       option(TTK_ENABLE_SCIKIT_LEARN "Enable scikit-learn support" ON)
 #    else()
 #       option(TTK_ENABLE_SCIKIT_LEARN "Enable scikit-learn support" OFF)
 #       message(STATUS
 #          "Improper python/numpy setup. Disabling sckikit-learn support in TTK.")
 #    endif()

 # endfunction()
