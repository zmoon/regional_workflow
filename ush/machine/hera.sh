#!/bin/bash

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model location

  external_model=${1}
  external_file_fmt=${2}

  location=""
  case ${external_model} in

    "FV3GFS")
      location='/scratch1/NCEPDEV/rstprod/com/gfs/prod/gfs.${yyyymmdd}/${hh}/atmos'
      ;;

  esac
  echo ${location:-}

}

EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_LBCS})}

# System scripts to source to initialize various commands within workflow
# scripts (e.g. "module").
if [ -z ${ENV_INIT_SCRIPTS_FPS:-""} ]; then
  ENV_INIT_SCRIPTS_FPS=( "/etc/profile" )
fi

# Commands to run at the start of each workflow task.
PRE_TASK_CMDS='{ ulimit -s unlimited; ulimit -a; }'

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE=${NCORES_PER_NODE:-40}
SCHED=${SCHED:-"slurm"}
PARTITION_DEFAULT=${PARTITION_DEFAULT:-"hera"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
PARTITION_HPSS=${PARTITION_HPSS:-"service"}
QUEUE_HPSS=${QUEUE_HPSS:-"batch"}
PARTITION_FCST=${PARTITION_FCST:-"hera"}
QUEUE_FCST=${QUEUE_FCST:-"batch"}

# UFS SRW App specific paths
FIXgsm=${FIXgsm:-"/scratch1/NCEPDEV/global/glopara/fix/fix_am"}
FIXaer=${FIXaer:-"/scratch1/NCEPDEV/global/glopara/fix/fix_aer"}
FIXlut=${FIXlut:-"/scratch1/NCEPDEV/global/glopara/fix/fix_lut"}
TOPO_DIR=${TOPO_DIR:-"/scratch1/NCEPDEV/global/glopara/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/scratch1/NCEPDEV/global/glopara/fix/fix_sfc_climo"}
FIXLAM_NCO_BASEDIR=${FIXLAM_NCO_BASEDIR:-"/scratch2/BMC/det/FV3LAM_pregen"}

# RRFS-CMAQ specific paths
AQM_CONFIG_DIR=${AQM_CONFIG_DIR:-"/scratch2/NCEPDEV/naqfc/RRFS_CMAQ/aqm/epa/data"}
AQM_BIO_DIR=${AQM_BIO_DIR:-"/scratch2/NCEPDEV/naqfc/RRFS_CMAQ/aqm/bio"}
AQM_FIRE_DIR=${AQM_FIRE_DIR:-"/scratch2/NCEPDEV/naqfc/RRFS_CMAQ/emissions/GSCE/GBBEPx.in.C401/Reprocessed"}
AQM_LBCS_DIR=${AQM_LBCS_DIR:-"/scratch2/NCEPDEV/naqfc/RRFS_CMAQ/LBCS/boundary_conditions_v4"}
AQM_GEFS_DIR=${AQM_GEFS_DIR:-"/scratch2/NCEPDEV/naqfc/RRFS_CMAQ/GEFS_aerosol"}
NEXUS_INPUT_DIR=${NEXUS_INPUT_DIR:-"/scratch1/NCEPDEV/rstprod/nexus_emissions"}
NEXUS_FIX_DIR=${NEXUS_FIX_DIR:-"/scratch2/NCEPDEV/naqfc/RRFS_CMAQ/nexus/fix"}

# Run commands for executables
RUN_CMD_SERIAL="time"
RUN_CMD_UTILS="srun"
RUN_CMD_FCST="srun"
RUN_CMD_POST="srun"

# MET Installation Locations
MET_INSTALL_DIR="/contrib/met/10.0.0"
METPLUS_PATH="/contrib/METplus/METplus-4.0.0"
CCPA_OBS_DIR="/scratch2/BMC/det/UFS_SRW_app/develop/obs_data/ccpa/proc"
MRMS_OBS_DIR="/scratch2/BMC/det/UFS_SRW_app/develop/obs_data/mrms/proc"
NDAS_OBS_DIR="/scratch2/BMC/det/UFS_SRW_app/develop/obs_data/ndas/proc"
MET_BIN_EXEC="bin"

# Test Data Locations
TEST_PREGEN_BASEDIR="/scratch2/BMC/det/FV3LAM_pregen"
TEST_COMINgfs="/scratch2/NCEPDEV/fv3-cam/noscrub/UFS_SRW_App/COMGFS"
TEST_EXTRN_MDL_SOURCE_BASEDIR="/scratch2/BMC/det/Gerard.Ketefian/UFS_CAM/staged_extrn_mdl_files"
TEST_ALT_EXTRN_MDL_SYSBASEDIR_ICS="/scratch2/BMC/det/UFS_SRW_app/dummy_FV3GFS_sys_dir"
TEST_ALT_EXTRN_MDL_SYSBASEDIR_LBCS="/scratch2/BMC/det/UFS_SRW_app/dummy_FV3GFS_sys_dir"
