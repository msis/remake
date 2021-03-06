############################################################################
#    Copyright (C) 2013 by Ralf Kaestner                                   #
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

### \brief ReMake Qt4 macros
#   The ReMake Qt4 macros provide seamless integration of Qt4 meta-object
#   and user interface file processing with ReMake build targets.

if(NOT DEFINED REMAKE_QT4_CMAKE)
  remake_set(REMAKE_QT4_CMAKE ON)
endif(NOT DEFINED REMAKE_QT4_CMAKE)

### \brief Configure Qt4 meta-object processing.
#   This macro discovers the Qt4 package configuration and enables Qt4
#   meta-object processing. Note that the macro automatically gets
#   invoked by the macros defined in this module. It needs not be called
#   directly from a CMakeLists.txt file.
#   \optional[list] REQUIRED:module An optional list of required Qt4
#     modules.
macro(remake_qt4)
  remake_arguments(PREFIX qt4_ LIST REQUIRED ${ARGN})
  
  if(NOT DEFINED QT4_FOUND)
    if(qt4_required)
      remake_find_package(Qt4 REQUIRED ${qt4_required} QUIET)
    else(qt4_required)
      remake_find_package(Qt4 QUIET)
    endif(qt4_required)
  else(NOT DEFINED QT4_FOUND)
    include(FindQt4)
  endif(NOT DEFINED QT4_FOUND)
  
  if(DEFINED QT4_FOUND AND NOT DEFINED QT4_MOC)
    remake_project_set(QT4_MOC ${QT4_FOUND} CACHE BOOL
      "Process Qt4 meta-objects.")
    remake_project_set(QT4_UIC ${QT4_FOUND} CACHE BOOL
      "Process Qt4 user interface files.")
  endif(DEFINED QT4_FOUND AND NOT DEFINED QT4_MOC)
endmacro(remake_qt4)

### \brief Add the Qt4 header directories to the include path.
#   This macro adds the Qt4 header directories to the compiler's include path.
macro(remake_qt4_include)
  remake_qt4()

  if(QT4_FOUND)
    remake_include(${QT_INCLUDES})
  endif(QT4_FOUND)
endmacro(remake_qt4_include)

### \brief Add Qt4 meta-object sources for a target.
#   This macro automatically defines meta-object sources for a target from
#   a list of glob expressions. The glob expressions should resolve to
#   header files containing a Q_OBJECT declaration.
#   \required[value] target The name of the target to add the meta-object
#     sources for.
#   \optional[list] glob An optional list of glob expressions that are
#     resolved in order to find the header files with Q_OBJECT declarations,
#     defaulting to *.h and *.hpp.
macro(remake_qt4_moc qt4_target)
  remake_arguments(PREFIX qt4_ ARGN globs ${ARGN})
  remake_set(qt4_globs SELF DEFAULT *.h DEFAULT *.hpp)

  remake_qt4()

  remake_project_get(QT4_MOC)
  if(QT4_MOC)
    remake_file_glob(qt4_headers ${qt4_globs})
    remake_unset(qt4_sources)
    qt4_wrap_cpp(qt4_sources ${qt4_headers} OPTIONS -nw)
    remake_target_add_sources(${qt4_target} ${qt4_sources})
  endif(QT4_MOC)
endmacro(remake_qt4_moc)

### \brief Generate headers from Qt4 user interface files.
#   This macro automatically generates header files from a list of glob
#   expressions that resolve to Qt user interface files. Furthermore,
#   the output location of the headers will be added to the compiler's
#   include path.
#   \required[value] target The name of the target to add the generated
#     headers for.
#   \optional[list] glob An optional list of glob expressions that are
#     resolved in order to find the Qt4 user interface files, defaulting
#     to *.ui.
macro(remake_qt4_ui qt4_target)
  remake_arguments(PREFIX qt4_ ARGN globs ${ARGN})
  remake_set(qt4_globs SELF DEFAULT *.ui)

  remake_qt4()

  remake_project_get(QT4_UIC)
  if(QT4_UIC)
    remake_file_glob(qt4_uis ${qt4_globs})
    remake_unset(qt4_headers)
    qt4_wrap_ui(qt4_headers ${qt4_uis})
    remake_target_add_sources(${qt4_target} ${qt4_headers})
    remake_include(${CMAKE_CURRENT_BINARY_DIR})
  endif(QT4_UIC)
endmacro(remake_qt4_ui)
