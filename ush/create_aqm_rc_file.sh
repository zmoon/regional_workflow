#
#-----------------------------------------------------------------------
#
# This file defines a function that creates an aqm.rc file
# in the specified run directory.
#
#-----------------------------------------------------------------------
#
function create_aqm_rc_file() {
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
  { save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
  local scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
  local scrfunc_fn=$( basename "${scrfunc_fp}" )
  local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
  local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=(
cdate \
run_dir \
init_concentrations \
  )
  process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
  print_input_args valid_args
#
#-----------------------------------------------------------------------
#
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local yyyymmdd \
        mm \
        aqm_rc_bio_file_fp \
        aqm_rc_canopy_file_fp \
        aqm_rc_fire_file_fp \
        aqm_rc_fp \
        settings

#-----------------------------------------------------------------------
#
# Create an aqm.rc file in the specified run directory.
#
#-----------------------------------------------------------------------
#
  print_info_msg "$VERBOSE" "
Creating an aqm.rc file (\"${AQM_RC_FN}\") in the specified run directory (run_dir):
  run_dir = \"${run_dir}\""

  aqm_rc_fp="${run_dir}/${AQM_RC_FN}"
#
# Extract from cdate the starting year, month, and day of the forecast.
#
  yyyymmdd=${cdate:0:8}
#
# Extract from cdate the starting month of the forecast.
#
  mm=${cdate:4:2}
#
# Set parameters in the aqm.rc file.
#
  aqm_rc_bio_file_fp="${AQM_BIO_DIR}/${AQM_BIO_FILE}"
  aqm_rc_canopy_file_fp="${AQM_CANOPY_DIR}/${AQM_CANOPY_FILE}${mm}${AQM_CANOPY_FILE_SUFFIX}"
  aqm_rc_fire_file_fp="${AQM_FIRE_DIR}/${yyyymmdd}/${AQM_FIRE_FILE}_${yyyymmdd}${AQM_FIRE_FILE_SUFFIX}"
#
#-----------------------------------------------------------------------
#
# Create a multiline variable that consists of a yaml-compliant string
# specifying the values that the jinja variables in the template 
# aqm.rc file should be set to.
#
#-----------------------------------------------------------------------
#
  settings="\
  'aqm_config_dir': ${AQM_CONFIG_DIR}
  'init_concentrations': ${init_concentrations}
  'aqm_rc_bio_file_fp': ${aqm_rc_bio_file_fp}
  'aqm_rc_canopy_file_fp': ${aqm_rc_canopy_file_fp}
  'aqm_bio_dir': ${AQM_BIO_DIR}
  'aqm_rc_fire_file_fp': ${aqm_rc_fire_file_fp}
  'aqm_rc_fire_frequency': ${AQM_RC_FIRE_FREQUENCY}"

  print_info_msg $VERBOSE "
The variable \"settings\" specifying values to be used in the aqm.rc
file has been set as follows:
settings =
$settings"
#
#-----------------------------------------------------------------------
#
# Call a python script to generate the experiment's actual AQM_RC_FN file
# from the template file.
#
#-----------------------------------------------------------------------
#
  $USHDIR/fill_jinja_template.py -q \
                                 -u "${settings}" \
                                 -t ${AQM_RC_TMPL_FP} \
                                 -o ${aqm_rc_fp} || \
  print_err_msg_exit "\
Call to python script fill_jinja_template.py to create \"${AQM_RC_FN}\" file
from a jinja2 template failed.  Parameters passed to this script are:
  Full path to user-owned template aqm.rc file:
    AQM_RC_TMPL_FP = \"${AQM_RC_TMPL_FP}\"
  Full path to actual input aqm.rc file:
    aqm_rc_fp = \"${aqm_rc_fp}\"
  Namelist settings specified on command line:
    settings =
$settings"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}

