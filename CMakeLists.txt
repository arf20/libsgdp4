cmake_minimum_required(VERSION 3.10)

project(libsgdp4)

file (GLOB SRC 
    "src/*.c"
)

add_library(sgdp4_shared SHARED ${SRC})
target_include_directories(sgdp4_shared PRIVATE "include/" "include/sigutils/")
set_target_properties(sgdp4_shared PROPERTIES OUTPUT_NAME sgdp4)

add_library(sgdp4_static STATIC ${SRC})
target_include_directories(sgdp4_static PRIVATE "include/" "include/sigutils/")
set_target_properties(sgdp4_static PROPERTIES OUTPUT_NAME sgdp4)

# shared install
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/)

include(GNUInstallDirs)
include(PcFileGenerator)

target_pc_file_generate(sgdp4_shared "SGDP-4 library")

install(TARGETS sgdp4_shared LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT LIB)
install(DIRECTORY include/sgdp4 DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT DEVEL)
install(FILES ${PROJECT_BINARY_DIR}/sgdp4_shared.pc DESTINATION ${CMAKE_INSTALL_PKGCONFIGDIR} COMPONENT DEVEL)

# General packaging settings
set(CPACK_PACKAGE_NAME sgdp4)
set(CPACK_PACKAGE_DIRECTORY ${PROJECT_BINARY_DIR}/dist)
set(CPACK_GENERATOR "DEB;TGZ")

# DEB packaging settings
set(CPACK_DEB_COMPONENT_INSTALL ON)
if(GITVERSIONDETECT_VERSION_COMMIT_NUM)
  set(CPACK_DEBIAN_PACKAGE_VERSION 0.1)
endif()
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "arf20 <aruizfernandez05@gmail.com>")
#set(CPACK_DEBIAN_LIB_PACKAGE_DEPENDS "libsndfile1 (>= 1.0.31-2build1), libvolk2.5 (>= 2.5.1-1), libfftw3-single3 (>= 3.3.8-2)")
#set(CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS "libsndfile1-dev (>= 1.0.31-2build1), libvolk2-dev (>= 2.5.1-1), libfftw3-dev (>= 3.3.8-2)")
set(CPACK_DEBIAN_LIB_PACKAGE_NAME "libsgdp4")
set(CPACK_DEBIAN_DEVEL_PACKAGE_NAME "libsgdp4-dev")
set(CPACK_DEBIAN_LIB_PACKAGE_SECTION "libs")
set(CPACK_DEBIAN_DEVEL_PACKAGE_SECTION "libdevel")

# Include CPack
include(CPack)

# CPack component information
cpack_add_component(LIB DISPLAY_NAME "Runtime library")
cpack_add_component(DEVEL DISPLAY_NAME "Development files" DEPENDS LIB)
