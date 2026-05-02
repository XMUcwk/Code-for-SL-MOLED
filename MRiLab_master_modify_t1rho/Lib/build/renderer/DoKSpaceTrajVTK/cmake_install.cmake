# Install script for directory: /data4/angus_wj/MRiLab/MRiLab_master1/Lib/src/renderer/DoKSpaceTrajVTK

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/data4/angus_wj/MRiLab/MRiLab_master1/Lib/src")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64"
         RPATH "")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/../bin" TYPE SHARED_LIBRARY FILES "/data4/angus_wj/MRiLab/MRiLab_master1/Lib/build/renderer/DoKSpaceTrajVTK/DoKSpaceTrajVTK.mexa64")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64"
         OLD_RPATH "/usr/local/anaconda3/pkgs/qt-5.6.0-0/lib:/usr/local/MATLAB/R2018a/bin/glnxa64:/usr/local/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/../bin/DoKSpaceTrajVTK.mexa64")
    endif()
  endif()
endif()

