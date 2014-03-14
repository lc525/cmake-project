## Configuration options

configure_project(0 1 0
                 ${CMAKE_CURRENT_SOURCE_DIR}/include
                 ${PROJECT_BINARY_DIR})

include_directories("${PROJECT_BINARY_DIR}")

# Below is just an example. uncomment/delete as needed
#
#set(RING_FLAGS "-std=c++11")
#set (common_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

## Unit tests
#if(WITH_TESTS)

  #set(exception_UNIT_TESTS
      #tests/exception_test.cpp)

  #set(ring_UNIT_TESTS
      #tests/ring_test.cpp)

  ## Enable gcc profiling
  ##set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pg")
  ##
  ## Detailed gdwarf debug information (for pahole)
  ##set(CMAKE_CXX_FLAGS_DEBUG "-O0 -gdwarf-2 -gstrict-dwarf")

  #set_source_files_properties(${ring_UNIT_TESTS}
                              #PROPERTIES COMPILE_FLAGS ${RING_FLAGS})
  #set(RING_LINK pthread rt ${GTEST_LIBRARY} ${GTEST_MAIN_LIBRARY})

  #lib_test(exception_UnitTest "${exception_UNIT_TESTS}")
  #lib_test(ring_UnitTest "${ring_UNIT_TESTS}" "${RING_LINK}" "--gtest_filter=*Functional*")

#endif(WITH_TESTS)

## shm_ring
#set(shm_ring_SOURCES
  #${common_SOURCE_DIR}/shm_ring.cpp)
#set_source_files_properties(${shm_ring_SOURCES}
                            #PROPERTIES COMPILE_FLAGS ${RING_FLAGS})
#add_executable(shm_ring ${shm_ring_SOURCES})
#target_link_libraries(shm_ring rt ${Boost_SYSTEM_LIBRARY} ${Boost_LOG_LIBRARY})
