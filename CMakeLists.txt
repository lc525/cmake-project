# global build file
# author: Lucian Carata <lc525@cam.ac.uk>
#
# Build options/features:
#
# Run cmake from a separate build directory (out of source build is
# recommended).
#
# Available option list, add -D[OPTION_NAME]=ON to enable:
#   - WITH_DOCS          - build project API documentation
#        default:   OFF
#        requires:  doxygen (build time dependency)
#
#   - WITH_SPHINX_MANUAL - if WITH_DOCS is ON, you can set this option
#                          to build a full html (sphinx) documentation.
#        default:   ON when WITH_DOCS is ON
#        requires:  python3
#                   sphinx (sphinx-doc.org)
#
#   - WITH_TESTS         - build the unit tests for each project. run them
#                          with "make check" after running make.
#        default:   ON
#        requires:  gtest (bundled with this project)
#        provides:  make target named "check"
#
# sample command line:
# [..build]$ cmake -DWITH_DOCS=ON ..
#
cmake_minimum_required(VERSION 2.8)

# change the project name here by setting PNAME. default is "generic".
#
set(PNAME generic)

# set default project build options:
set(DEFAULT_WITH_TESTS OFF)
set(DEFAULT_WITH_DOCS OFF)

# General cmake project definition follows. Customize as necessary
project(${PNAME})

# variable definitions for generating configuration headers
set(${PNAME}_MAJOR_VERSION 0)
set(${PNAME}_MINOR_VERSION 1)
execute_process(
  COMMAND git --git-dir ${${PNAME}_SOURCE_DIR}/.git rev-parse --short HEAD
    OUTPUT_VARIABLE GIT_REV
)
string(REPLACE "\n" "" GIT_REV ${GIT_REV})
set(${PNAME}_PATCH_VERSION ${GIT_REV})
set(${PNAME}_VERSION
  ${${PNAME}_MAJOR_VERSION}.${${PNAME}_MINOR_VERSION}.${${PNAME}_PATCH_VERSION})



###
#
#  CMAKE MODULES
#
###
set(CMAKE_MODULE_PATH ${${PNAME}_SOURCE_DIR}/cmake/modules ${CMAKE_MODULE_PATH})
set(CMAKE_MODULE_PATH ${${PNAME}_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(CMakeDependentOption)
include(FeatureSummary)
# custom modules
include(MacroOutOfSourceBuild)
include(InternalMacros)



###
#
# OPTIONS
#
###
option(WITH_DOCS
  "Build ${PROJECT_NAME} documentation (API doxygen + manual)" OFF)
cmake_dependent_option(WITH_SPHINX_MANUAL
  "Generate the html manual" ON "WITH_DOCS" OFF)
option(WITH_TESTS
  "Build ${PROJECT_NAME} tests" ON)

#Google Testing Framework
# the options are mutually exclusive and are listed in order of preference,
# but if Gtest is not found using the given option the other ones will be
# attempted in turn.
option(USE_PROJECT_GTEST # recommended, automatic fallthrough
  "Use the local Gtest, if found within project subdirectories" ON)
option(USE_REPO_GTEST
  "Download and build gtest from online repository during make" OFF)
#option(USE_SYSTEM_GTEST
#  "Attempt using the system-wide Gtest installation" OFF)

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
message("!! Build type: ${CMAKE_BUILD_TYPE}")



###
#
# DEPENDENCIES
#
###
include(ExternalProject)
# Boost
set(BOOST_USE_STATIC_LIBS OFF)
set(BOOST_USE_MULTITHREADED ON)
set(BOOST_USE_STATIC_RUNTIME OFF)
find_package(Boost 1.46.0 REQUIRED COMPONENTS log system)

if(Boost_FOUND)
  include_directories( ${BOOST_INCLUDE_DIRS} )
endif()

# Google Testing Framework
set(FALLTHROUGH "0")
if(USE_PROJECT_GTEST)
  find_package(gtest)
  if(NOT GTEST_FOUND)
    set(FALLTHROUGH "1")
  endif()
endif()
if(USE_REPO_GTEST OR FALLTHROUGH STREQUAL "1")
  set(FALLTHROUGH "0")
  set(GTEST_PREFIX ${CMAKE_SOURCE_DIR}/external/gtest)
  MESSAGE(" \\-- Gtest will be downloaded and built in ${GTEST_PREFIX}")
  ExternalProject_Add(
      gtest
      PREFIX ${CMAKE_SOURCE_DIR}/build/gtest
      GIT_REPOSITORY https://github.com/lc525/gtest.git
      GIT_TAG release-1.7.0
      CMAKE_ARGS
          -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      INSTALL_COMMAND ""
      UPDATE_COMMAND ""
      TMP_DIR ${CMAKE_SOURCE_DIR}/build/gtest
      STAMP_DIR ${CMAKE_SOURCE_DIR}/build/gtest
      DOWNLOAD_DIR ${GTEST_PREFIX}
      SOURCE_DIR ${GTEST_PREFIX}
      BINARY_DIR ${GTEST_PREFIX}/build-aux
  )
  set(GTEST_LIBRARY "${GTEST_PREFIX}/build-aux/libgtest.a")
  set(GTEST_MAIN_LIBRARY "${GTEST_PREFIX}/build-aux/libgtest_main.a")
  set(GTEST_INCLUDE_DIR "${GTEST_PREFIX}/include")

  set(GTEST_LIBRARIES ${GTEST_LIBRARY})
  set(GTEST_MAIN_LIBRARIES ${GTEST_MAIN_LIBRARY})
  set(GTEST_INCLUDE_DIRS ${GTEST_INCLUDE_DIR})
endif()
#  if(USE_SYSTEM_GTEST)
#endif()

if(WITH_TESTS)
  add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} -V)
  enable_testing()
endif(WITH_TESTS)

# Capnproto
set(CAPNPROTO_PREFIX ${CMAKE_SOURCE_DIR}/external/capnproto)
find_package(capnproto)
if(NOT CAPNPROTO_FOUND)
  MESSAGE(" \\-- Capnproto will be downloaded and built in ${CAPNPROTO_PREFIX}")
  ExternalProject_Add(capnproto
      GIT_REPOSITORY https://github.com/lc525/capnproto.git
      PREFIX ${CMAKE_SOURCE_DIR}/build/capnproto
      GIT_TAG cmake_local
      CMAKE_ARGS
          -DUSE_SUBMODULE_GTEST=ON
          -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
          -DGTEST_LIBRARY=${GTEST_LIBRARY}
          -DGTEST_MAIN_LIBRARY=${GTEST_MAIN_LIBRARY}
          -DGTEST_INCLUDE_DIRECTORIES=${GTEST_INCLUDE_DIRS}
      INSTALL_COMMAND ""
      UPDATE_COMMAND ""
      TMP_DIR ${CMAKE_SOURCE_DIR}/build/capnproto
      STAMP_DIR ${CMAKE_SOURCE_DIR}/build/capnproto
      DOWNLOAD_DIR ${CAPNPROTO_PREFIX}
      SOURCE_DIR ${CAPNPROTO_PREFIX}
      BINARY_DIR ${CAPNPROTO_PREFIX}/build-aux
  )
  ExternalProject_Add_Step(capnproto prebuild
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CAPNPROTO_PREFIX}/build-aux
    DEPENDEES download
    DEPENDERS configure
  )
  set(CAPNP_LIBRARY "${CAPNPROTO_PREFIX}/build-aux/c++/libcapnp.so")
  set(CAPNP_RPC_LIBRARY "${CAPNPROTO_PREFIX}/build-aux/c++/libcapnp-rpc.so")
  set(CAPNPC_LIBRARY "${CAPNPROTO_PREFIX}/build-aux/c++/libcapnpc.so")
  set(KJ_LIBRARY "${CAPNPROTO_PREFIX}/build-aux/c++/libkj.so")
  set(KJ_ASYNC_LIBRARY "${CAPNPROTO_PREFIX}/build-aux/c++/libkj-async.so")
  set(CAPNPC_EXECUTABLE "${CAPNPROTO_PREFIX}/build-aux/c++/capnp")
  set(CAPNPC_CXX_EXECUTABLE "${CAPNPROTO_PREFIX}/build-aux/c++/capnpc-c++")
  set(CAPNP_INCLUDE_DIRECTORIES "${CAPNPROTO_PREFIX}/c++/src")
  list(APPEND CAPNP_LIBRARIES ${CAPNP_RPC_LIBRARY})
  list(APPEND CAPNP_LIBRARIES ${CAPNP_LIBRARY})
  list(APPEND CAPNP_LIBRARIES ${CAPNPC_LIBRARY})
  list(APPEND CAPNP_LIBRARIES ${KJ_ASYNC_LIBRARY})
  list(APPEND CAPNP_LIBRARIES ${KJ_LIBRARY})
  if(NOT GTEST_FOUND)
    add_dependencies(capnproto gtest)
  endif(NOT GTEST_FOUND)
endif(NOT CAPNPROTO_FOUND)

set(CAPNPC_IMPORT_PATH ${CAPNPROTO_PREFIX}/c++/src)


###
#
# BUILD
#
###
ensure_out_of_source_build("${PROJECT_NAME} requires an out of source build. ")

configure_project(${${PNAME}_MAJOR_VERSION} ${${PNAME}_MINOR_VERSION} ${${PNAME}_PATCH_VERSION}
                 ${CMAKE_CURRENT_SOURCE_DIR}/include
                 ${CMAKE_CURRENT_BINARY_DIR})
set(GEN_INCLUDE_DIR ${PROJECT_BINARY_DIR} CACHE STRING "include for gen configs")

# common includes and project settings
include_directories("${GEN_INCLUDE_DIR}") # for generated configs
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/external/ezOptionParser")

set (${PNAME}_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set (${PNAME}_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

###
## Project Sources and Tests
##
## Example adding project sources
#set (tigstore_SOURCES
    #${tigstore_SOURCE_DIR}/particle.cpp
    #${tigstore_SOURCE_DIR}/alloc.cpp
#)

#set (tigstore_HEADERS
    #${tigstore_INCLUDE_DIR}/particle.h
    #${tigstore_INCLUDE_DIR}/util.h
    #${tigstore_INCLUDE_DIR}/alloc.h
#)

#set(tigstore_LINK pthread ${GTEST_LIBRARY} ${GTEST_MAIN_LIBRARY})

###
## Executable example:

#add_executable(${PNAME} ${tigstore_SOURCES})
#target_link_libraries(${PNAME} ${tigstore_LINK})
