################################################################################
# \file Makefile
# \version 1.0
#
# \brief
# Top-level application make file.
#
################################################################################
# \copyright
# Copyright 2018-2023, Cypress Semiconductor Corporation (an Infineon company)
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################


################################################################################
# Basic Configuration
################################################################################

# Type of ModusToolbox Makefile Options include:
#
# COMBINED    -- Top Level Makefile usually for single standalone application
# APPLICATION -- Top Level Makefile usually for multi project application
# PROJECT     -- Project Makefile under Application
#
MTB_TYPE=COMBINED

# Target board/hardware (BSP).
# To change the target, it is recommended to use the Library manager
# ('make library-manager' from command line), which will also update Eclipse IDE launch
# configurations.
TARGET=CYW955913EVK-01

ACTUAL_TARGET=$(subst APP_,,$(TARGET))
$(info TARGET = $(TARGET))
$(info ACTUAL = $(ACTUAL_TARGET))

# Name of application (used to derive name of final linked file).
#
# If APPNAME is edited, ensure to update or regenerate launch
# configurations for your IDE.
APPNAME=mtb-example-threadx-wifi-ota-mqtt

# Name of toolchain to use. Options include:
#
# GCC_ARM -- GCC provided with ModusToolbox software
# ARM     -- ARM Compiler (must be installed separately)
# IAR     -- IAR Compiler (must be installed separately)
#
# See also: CY_COMPILER_PATH below
TOOLCHAIN=GCC_ARM

# Default build configuration. Options include:
#
# Debug -- build with minimal optimizations, focus on debugging.
# Release -- build with full optimizations
# Custom -- build with custom configuration, set the optimization flag in CFLAGS
#
# If CONFIG is manually edited, ensure to update or regenerate launch configurations
# for your IDE.
CONFIG=Debug

# If set to "true" or "1", display full command-lines when building.
VERBOSE=


################################################################################
# Advanced Configuration
################################################################################

# Enable optional code that is ordinarily disabled by default.
#
# Available components depend on the specific targeted hardware and firmware
# in use. In general, if you have
#
#    COMPONENTS=foo bar
#
# ... then code in directories named COMPONENT_foo and COMPONENT_bar will be
# added to the build
#
COMPONENTS=

# Like COMPONENTS, but disable optional code that was enabled by default.
DISABLE_COMPONENTS=

# By default the build system automatically looks in the Makefile's directory
# tree for source code and builds it. The SOURCES variable can be used to
# manually add source code to the build process from a location not searched
# by default, or otherwise not found by the build system.
SOURCES=

# Like SOURCES, but for include directories. Value should be paths to
# directories (without a leading -I).
INCLUDES=

# Add additional defines to the build process (without a leading -D).
DEFINES+=CY_RTOS_AWARE CY_RETARGET_IO_CONVERT_LF_TO_CRLF 

# Select softfp or hardfp floating point. Default is softfp.
VFP_SELECT=

# Additional / custom C compiler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
CFLAGS=

# Additional / custom C++ compiler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
CXXFLAGS=

# Additional / custom assembler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
ASFLAGS=

# Additional / custom linker flags.
LDFLAGS=

# Additional / custom libraries to link in to the application.
LDLIBS=

# Path to the linker script to use (if empty, use the default linker script).
LINKER_SCRIPT=

# Custom pre-build commands to run.
PREBUILD=

# Custom post-build commands to run.
POSTBUILD=

####################################################################################
# Common COMPONENTS and DEFINES
####################################################################################

# Common components across all TARGETS
COMPONENTS+=WCM SECURE_SOCKETS

# TODO: Look through the DEFINES to see if these are already defined, don't need to do it twice
DEFINES+= CY_RETARGET_IO_CONVERT_LF_TO_CRLF

DEFINES+=TX_PACKET_POOL_SIZE=10
DEFINES+=RX_PACKET_POOL_SIZE=16
DEFINES+=SECURE_SOCKETS_THREAD_STACKSIZE=1024
DEFINES+=WHD_PRINT_DISABLE

# Add additional defines to the build process (without a leading -D).
DEFINES+=COMPONENT_WIFI_INTERFACE_OCI CYBSP_WIFI_CAPABLE HAVE_SNPRINTF CY_RTOS_AWARE CY_WIFI_COUNTRY=WHD_COUNTRY_UNITED_STATES

DEFINES+=NX_SECURE_INCLUDE_USER_DEFINE_FILE NX_INCLUDE_USER_DEFINE_FILE CY_TLS_DEFAULT_ALLOW_SHA1_CIPHER

# Upgrade Slot size.
DEFINES+=CY_DS_SIZE=0x3C0000

# Custom configuration of mbedtls library.
DEFINES+=MBEDTLS_CONFIG_FILE='"mbedtls/config-cc312-h1cp-no-os.h"'
#HEAP_SIZE=0x22000

################################################################################
################################################################################
# Basic OTA configuration
################################################################################
################################################################################

# Set to 1 to add OTA defines, sources, and libraries (must be used with MCUBoot)
# NOTE: Extra code must be called from your app to initialize the OTA middleware.
OTA_SUPPORT=1

ifeq ($(OTA_SUPPORT),1)

    ################################################################################
    #
    # OTA Build debugging
    #
    # OTA_BUILD_VERBOSE=1              Output info about Defines
    # OTA_BUILD_FLASH_VERBOSE=1        Output info about Flash layout
    # OTA_BUILD_COMPONENTS_VERBOSE=1   Output info about COMPONENTS, DEFINES, CY_IGNORE
    # OTA_BUILD_DEFINES_VERBOSE=1      Output info about DEFINES
    # OTA_BUILD_IGNORE_VERBOSE=1       Output info about CY_IGNORE
    # OTA_BUILD_POST_VERBOSE=1         Output info about POSTBUILD values
    #
    #
    ###############################################################################
    # Set to 1 to get more OTA Makefile / Build information for debugging build issues
    OTA_BUILD_VERBOSE=

    CY_BOOTLOADER?=H1_CP
    CY_TARGET_BOARD=$(subst -,_,$(ACTUAL_TARGET))
    $(info Makefile: CY_TARGET_BOARD : $(CY_TARGET_BOARD))
    DEFINES+=CY_TARGET_BOARD=$(CY_TARGET_BOARD)

    # Define to enable OTA logs
    DEFINES+=ENABLE_OTA_LOGS ENABLE_OTA_BOOTLOADER_ABSTRACTION_LOGS
    
    # Dependent library Logs
  #  DEFINES+=ENABLE_MQTT_LOGS ENABLE_HTTP_CLIENT_LOGS ENABLE_AWS_PORT_LOGS ENABLE_SECURE_SOCKETS_LOGS

    # Add Boot loader support
    COMPONENTS+=$(CY_BOOTLOADER)

    # Supported Transfer Protocols.
    #
    # OTA_HTTP_SUPPORT
    # OTA_MQTT_SUPPORT
    # OTA_BT_SUPPORT
    #
    # If the application requires the support of multiple transfer protocols,
    # use one of more of OTA_<protocol>_SUPPORT Configurations.
    #
    # Atleast one of the protocols should be enabled by the application.
    # Otherwise, the included ota_update.mk throws an error.
    #
    OTA_MQTT_SUPPORT?=1
    OTA_HTTP_SUPPORT?=0
    OTA_BT_SUPPORT?=0


    # BLE Secure Mode
    #OTA_BT_SECURE?=0


    DEFINES+=JOB_FLOW=1

    # Enable for TLS Connection
    DEFINES+=OTA_TLS=1


    DEFINES+=MQTT_AWS_BROKER=1

        #CY_IGNORE+=$(SEARCH_connectivity-utilities)/network/
    

    # Change the version here or over-ride by setting an environment variable
    # before building the application.
    #
    # export APP_VERSION_MAJOR=2
    #

    APP_VERSION_MAJOR?=1
    APP_VERSION_MINOR?=0
    APP_VERSION_BUILD?=0

    DEFINES+= OTA_SUPPORT=1 \
    APP_VERSION_MAJOR=$(APP_VERSION_MAJOR) \
    APP_VERSION_MINOR=$(APP_VERSION_MINOR) \
    APP_VERSION_BUILD=$(APP_VERSION_BUILD)

    ifneq ($(MAKECMDGOALS),getlibs)
        ifneq ($(MAKECMDGOALS),get_app_info)
            ifneq ($(MAKECMDGOALS),printlibs)
                include ../mtb_shared/ota-update/*-v*/makefiles/ota_update.mk
            endif
        endif
    endif

    # This is required only for this pipeline.
    # These libraries are ignored based on the kits while building locally.
    ifeq ($(OTA_MQTT_SUPPORT),0)
        ifeq ($(OTA_HTTP_SUPPORT),0)
            CY_IGNORE+=$(SEARCH_aws-iot-device-sdk-embedded-C)/
            CY_IGNORE+=$(SEARCH_aws-iot-device-sdk-port)/
            TEST_ONLY_BT=1
        endif
    endif

    ifeq ($(OTA_MQTT_SUPPORT),0)
        CY_IGNORE+=$(SEARCH_mqtt)/
        CY_IGNORE+=$(SEARCH_aws-iot-device-sdk-embedded-C)/libraries/standard/coreMQTT/
    endif

    ifeq ($(OTA_HTTP_SUPPORT),0)
        CY_IGNORE+=$(SEARCH_http-client)/
        CY_IGNORE+=$(SEARCH_aws-iot-device-sdk-embedded-C)/libraries/standard/coreHTTP/
    endif

    CY_IGNORE+=$(SEARCH_aws-iot-device-sdk-embedded-C)/libraries/aws/ota-for-aws-iot-embedded-sdk
    CY_IGNORE+=$(SEARCH_aws-iot-device-sdk-port)/source/ota

endif # OTA_SUPPORT

################################################################################
# Paths
################################################################################

# Relative path to the project directory (default is the Makefile's directory).
#
# This controls where automatic source code discovery looks for code.
CY_APP_PATH=

# Relative path to the shared repo location.
#
# All .mtb files have the format, <URI>#<COMMIT>#<LOCATION>. If the <LOCATION> field
# begins with $$ASSET_REPO$$, then the repo is deposited in the path specified by
# the CY_GETLIBS_SHARED_PATH variable. The default location is one directory level
# above the current app directory.
# This is used with CY_GETLIBS_SHARED_NAME variable, which specifies the directory name.
CY_GETLIBS_SHARED_PATH=../

# Directory name of the shared repo location.
#
CY_GETLIBS_SHARED_NAME=mtb_shared

# Absolute path to the compiler's "bin" directory.
#
# The default depends on the selected TOOLCHAIN (GCC_ARM uses the ModusToolbox
# software provided compiler by default).
CY_COMPILER_PATH=


# Locate ModusToolbox helper tools folders in default installation
# locations for Windows, Linux, and macOS.
CY_WIN_HOME=$(subst \,/,$(USERPROFILE))
CY_TOOLS_PATHS ?= $(wildcard \
    $(CY_WIN_HOME)/ModusToolbox/tools_* \
    $(HOME)/ModusToolbox/tools_* \
    /Applications/ModusToolbox/tools_*)

# If you install ModusToolbox software in a custom location, add the path to its
# "tools_X.Y" folder (where X and Y are the version number of the tools
# folder). Make sure you use forward slashes.
CY_TOOLS_PATHS+=

# Default to the newest installed tools folder, or the users override (if it's
# found).
CY_TOOLS_DIR=$(lastword $(sort $(wildcard $(CY_TOOLS_PATHS))))

ifeq ($(CY_TOOLS_DIR),)
$(error Unable to find any of the available CY_TOOLS_PATHS -- $(CY_TOOLS_PATHS). On Windows, use forward slashes.)
endif

$(info Tools Directory: $(CY_TOOLS_DIR))

include $(CY_TOOLS_DIR)/make/start.mk
