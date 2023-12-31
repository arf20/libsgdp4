# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2023 Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>

#[=======================================================================[.rst:
PcFileGenerator
-------

This module attempts to automatically create a ".pc" for the desired library
targets.
Beware this module includes GNUInstallDirs module.

Result Variables
^^^^^^^^^^^^^^^^

``CMAKE_INSTALL_PKGCONFIGDIR``
  Installation directory for pkgconfig (.pc) files.

Custom functions
^^^^^^^^^^^^^^^^

``target_pc_file_generate``
  Generate a ".pc" file for the provided target.

#]=======================================================================]

# GNUInstallDirs_get_absolute_install_dir <dirname> parameter was added in 3.20
# https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html#command:gnuinstalldirs_get_absolute_install_dir
cmake_minimum_required(VERSION 3.20)

include(GNUInstallDirs)

# Define install paths
set(CMAKE_INSTALL_PKGCONFIGDIR  "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
GNUInstallDirs_get_absolute_install_dir(CMAKE_INSTALL_FULL_PKGCONFIGDIR CMAKE_INSTALL_PKGCONFIGDIR PKGCONFIGDIR)

# PC file template
set(PCFILEGENERATOR_PC_TEMPLATE "\
# @TARGET@ library pkg-config file
# Automatically generated by CMAKE

prefix=@CMAKE_INSTALL_PREFIX@
exec_prefix=\"\$\{prefix\}\"
libdir=\"\$\{prefix\}/@CMAKE_INSTALL_LIBDIR@\"
includedir=\"\$\{prefix\}/@CMAKE_INSTALL_INCLUDEDIR@\"

Name: @TARGET@
Description: @TARGET_DESCRIPTION@
URL: @PROJECT_HOMEPAGE_URL@
Version: @PROJECT_VERSION@ 
Cflags: -I\$\{includedir\} @COMPILE_FLAGS@
Libs: -L\$\{libdir\} -l@TARGET@ @LINK_FLAGS@
")

# PC file generation function
function(target_pc_file_generate TARGET TARGET_DESCRIPTION)
  # Get target linked libraries
  get_target_property(LINK_LIBRARIES ${TARGET} INTERFACE_LINK_LIBRARIES)
  
  # Fix crappy 3rd party modules
  string(REPLACE "^-l" "" LINK_LIBRARIES "${LINK_LIBRARIES}")
  string(REPLACE ";-l" ";" LINK_LIBRARIES "${LINK_LIBRARIES}")

  string(REPLACE ";" " -l" LINK_FLAGS "${LINK_LIBRARIES}")
  if (NOT "${LINK_FLAGS}" STREQUAL "")
    string(PREPEND LINK_FLAGS "-l")
  endif()

  
  # Get compiler flags
  get_target_property(COMPILE_DEFS ${TARGET} INTERFACE_COMPILE_DEFINITIONS)
  string(REPLACE ";" " -D" COMPILE_FLAGS "${COMPILE_DEFS}")
  if (NOT "${COMPILE_FLAGS}" STREQUAL "")
    string(PREPEND COMPILE_FLAGS "-D")
  endif()

  # Generate the PC file
  file(CONFIGURE OUTPUT ${TARGET}.pc CONTENT ${PCFILEGENERATOR_PC_TEMPLATE} @ONLY)
endfunction()
