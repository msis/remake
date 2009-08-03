############################################################################
#    Copyright (C) 2009 by Ralf 'Decan' Kaestner                           #
#    ralf.kaestner@gmail.com                                               #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

include(ReMakePrivate)

# Define the ReMake project.
macro(remake_project project_name project_version project_release 
  project_summary project_vendor project_contact project_home project_license)
  remake_arguments(PREFIX project_ VAR INSTALL VAR SOURCES ${ARGN})

  remake_set(REMAKE_PROJECT_NAME ${project_name})
  remake_file_name(REMAKE_PROJECT_FILENAME ${REMAKE_PROJECT_NAME})

  remake_set(project_regex "^([0-9]+)[.]?([0-9]*)[.]?([0-9]*)$")
  string(REGEX REPLACE ${project_regex} "\\1" REMAKE_PROJECT_MAJOR 
    ${project_version})
  string(REGEX REPLACE ${project_regex} "\\2" REMAKE_PROJECT_MINOR 
    ${project_version})
  string(REGEX REPLACE ${project_regex} "\\3" REMAKE_PROJECT_PATCH 
    ${project_version})
  remake_set(REMAKE_PROJECT_MAJOR SELF DEFAULT 0)
  remake_set(REMAKE_PROJECT_MINOR SELF DEFAULT 0)
  remake_set(REMAKE_PROJECT_PATCH SELF DEFAULT 0)
  remake_set(REMAKE_PROJECT_VERSION 
    ${REMAKE_PROJECT_MAJOR}.${REMAKE_PROJECT_MINOR}.${REMAKE_PROJECT_PATCH})
  remake_set(REMAKE_PROJECT_RELEASE ${project_release})

  remake_set(REMAKE_PROJECT_SUMMARY ${project_summary})
  remake_set(REMAKE_PROJECT_VENDOR ${project_vendor})
  remake_set(REMAKE_PROJECT_CONTACT ${project_contact})
  remake_set(REMAKE_PROJECT_HOME ${project_home})
  remake_set(REMAKE_PROJECT_LICENSE ${project_license})

  remake_set(REMAKE_PROJECT_BUILD_SYSTEM ${CMAKE_SYSTEM_NAME})
  remake_set(REMAKE_PROJECT_BUILD_ARCH ${CMAKE_SYSTEM_PROCESSOR})
  remake_set(REMAKE_PROJECT_BUILD_TYPE ${CMAKE_BUILD_TYPE})

  if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    remake_set(CMAKE_INSTALL_PREFIX ${project_install} DEFAULT /usr/local 
      CACHE PATH "Install path prefix, prepended onto install directories."
      FORCE)
  endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

  remake_project_set(LIBRARY_DESTINATION lib CACHE PATH 
    "Install destination of project libraries.")
  remake_project_set(EXECUTABLE_DESTINATION bin CACHE PATH 
    "Install destination of project executables.")
  remake_project_set(PLUGIN_DESTINATION 
    lib/${REMAKE_PROJECT_FILENAME} CACHE PATH
    "Install destination of project plugins.")
  remake_project_set(SCRIPT_DESTINATION bin CACHE PATH
    "Install destination of project scripts.")
  remake_project_set(FILE_DESTINATION share/${REMAKE_PROJECT_FILENAME} 
    CACHE PATH "Install destination of project files.")
  remake_project_set(HEADER_DESTINATION include/${REMAKE_PROJECT_FILENAME} 
    CACHE PATH "Install destination of project development headers.")

  message(STATUS "Project: ${REMAKE_PROJECT_NAME} "
    "version ${REMAKE_PROJECT_VERSION}, "
    "release ${REMAKE_PROJECT_RELEASE}")
  message(STATUS "Summary: ${REMAKE_PROJECT_SUMMARY}")
  message(STATUS "Vendor: ${REMAKE_PROJECT_VENDOR} (${REMAKE_PROJECT_CONTACT})")
  message(STATUS "Home: ${REMAKE_PROJECT_HOME}")
  message(STATUS "License: ${REMAKE_PROJECT_LICENSE}")

  project(${REMAKE_PROJECT_NAME})

  remake_set(REMAKE_PROJECT_SOURCE_DIR ${project_sources} DEFAULT src)
  if(EXISTS ${CMAKE_SOURCE_DIR}/${REMAKE_PROJECT_SOURCE_DIR})
    add_subdirectory(${REMAKE_PROJECT_SOURCE_DIR})
  endif(EXISTS ${CMAKE_SOURCE_DIR}/${REMAKE_PROJECT_SOURCE_DIR})
endmacro(remake_project)

# Define the value of a ReMake project variable. The variable name will
# automatically be prefixed with an upper-case conversion of the project name.
# Thus, variables may appear in the cache as ${PROJECT_NAME}_${VAR_NAME}.
macro(remake_project_set project_var)
  remake_var_name(project_global_var ${REMAKE_PROJECT_NAME} ${project_var})
  remake_set(${project_global_var} ${ARGN})
endmacro(remake_project_set)

# Retrieve the value of a ReMake project variable.
macro(remake_project_get project_var)
  remake_arguments(PREFIX project_ VAR OUTPUT ${ARGN})

  remake_var_name(project_global_var ${REMAKE_PROJECT_NAME} ${project_var})
  if(project_output)
    remake_set(${project_output} FROM ${project_global_var})
  else(project_output)
    remake_set(${project_var} FROM ${project_global_var})
  endif(project_output)
endmacro(remake_project_get)

# Define a ReMake project option. The option name will be converted into
# a ReMake project variable.
macro(remake_project_option project_option project_description project_default)
  remake_project_set(${project_option} ${project_default} CACHE BOOL
    "Compile with ${project_description}.")

  remake_project_get(${project_option})
  if(${project_option})
    message(STATUS "Compiling with ${project_description}.")
  else(${project_option})
    message(STATUS "NOT compiling with ${project_description}.")
  endif(${project_option})
endmacro(remake_project_option)

# Define the ReMake project prefix for libary, plugin, executable, script,
# and file names. By an empty argument list, this prefix defaults to the
# lower-case project name followed by a score.
macro(remake_project_prefix)
  remake_arguments(PREFIX project_ VAR LIBRARY VAR PLUGIN VAR EXECUTABLE 
    VAR SCRIPT VAR FILE ${ARGN})

  remake_set(REMAKE_LIBRARY_PREFIX ${project_library} 
    DEFAULT ${REMAKE_PROJECT_FILENAME}-)
  remake_set(REMAKE_PLUGIN_PREFIX ${project_plugin} 
    DEFAULT ${REMAKE_PROJECT_FILENAME}-)
  remake_set(REMAKE_EXECUTABLE_PREFIX ${project_executable}
    DEFAULT ${REMAKE_PROJECT_FILENAME}-)
  remake_set(REMAKE_SCRIPT_PREFIX ${project_script}
    DEFAULT ${REMAKE_PROJECT_FILENAME}-)
  remake_set(REMAKE_FILE_PREFIX ${project_file}
    DEFAULT ${REMAKE_PROJECT_FILENAME}-)
endmacro(remake_project_prefix)

# Define the ReMake project configuration header.
macro(remake_project_header project_source)
  remake_arguments(PREFIX project_ VAR HEADER ${ARGN})
  remake_assign(project_header SELF DEFAULT config.h)

  if(NOT REMAKE_PROJECT_HEADER)
    remake_set(REMAKE_PROJECT_HEADER 
      ${CMAKE_BINARY_DIR}/include/${project_header})
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${project_source} 
      ${REMAKE_PROJECT_HEADER})
    include_directories(${CMAKE_BINARY_DIR}/include)
  else(NOT REMAKE_PROJECT_HEADER)
    message(FATAL_ERROR "Duplicate project configuration header!") 
  endif(NOT REMAKE_PROJECT_HEADER)
endmacro(remake_project_header)
