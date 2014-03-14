set(CAPNP_PATH  ${CMAKE_SOURCE_DIR}/common/external/capnproto/build-aux/c++)
set(CAPNP_INCLUDE_DIRECTORIES "${CMAKE_SOURCE_DIR}/common/external/capnproto/c++/src")

find_program(CAPNPC_EXECUTABLE capnp
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH # ignore system capnproto if installed
)

find_program(CAPNPC_CXX_EXECUTABLE capnpc-c++
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

find_program(CAPNPC_CAPNP capnpc-capnp
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

find_library(CAPNP_RPC_LIBRARY
  NAMES capnp-rpc libcapnp-rpc
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

find_library(CAPNP_LIBRARY
  NAMES capnp libcapnp
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

find_library(CAPNPC_LIBRARY
  NAMES capnpc libcapnpc
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

find_library(KJ_ASYNC_LIBRARY
  NAMES kj-async libkj-async
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

find_library(KJ_LIBRARY
  NAMES kj libkj
  PATHS ${CAPNP_PATH}
  NO_DEFAULT_PATH
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(capnproto DEFAULT_MSG
  CAPNPC_EXECUTABLE
  CAPNPC_CXX_EXECUTABLE
  CAPNPC_CAPNP
  CAPNP_RPC_LIBRARY
  CAPNP_LIBRARY
  CAPNPC_LIBRARY
  KJ_ASYNC_LIBRARY
  KJ_LIBRARY
)

mark_as_advanced(
  CAPNPC_EXECUTABLE
  CAPNPC_CXX_EXECUTABLE
  CAPNPC_CAPNP
  CAPNP_RPC_LIBRARY
  CAPNP_LIBRARY
  CAPNPC_LIBRARY
  KJ_ASYNC_LIBRARY
  KJ_LIBRARY
)

set(CAPNPROTO_LOCAL_FOUND) # we have found capnproto locally within project path
                           # this means we have previously downloaded & built it

list(APPEND CAPNP_LIBRARIES ${CAPNP_RPC_LIBRARY})
list(APPEND CAPNP_LIBRARIES ${CAPNP_LIBRARY})
list(APPEND CAPNP_LIBRARIES ${CAPNPC_LIBRARY})
list(APPEND CAPNP_LIBRARIES ${KJ_ASYNC_LIBRARY})
list(APPEND CAPNP_LIBRARIES ${KJ_LIBRARY})

set_package_properties(capnproto PROPERTIES
  URL "https://github.com/kentov/capnproto"
  TYPE REQUIRED
  PURPOSE "capnproto serialization/RPC system")


