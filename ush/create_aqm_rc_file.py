#!/usr/bin/env python3

import os
import unittest
from datetime import datetime
from textwrap import dedent

from python_utils import import_vars, set_env_var, print_input_args, \
                         print_info_msg, print_err_msg_exit, lowercase, cfg_to_yaml_str

from fill_jinja_template import fill_jinja_template

def create_aqm_rc_file(cdate,run_dir,init_concentrations):
    """ Creates the aqm.rc file in the specified run directory

    Args:
        cdate: cycle date
        run_dir: run directory
        init_concentrations
    Returns:
        Boolean
    """

    print_input_args(locals())

    #import all environment variables
    import_vars()
    
    #
    #-----------------------------------------------------------------------
    #
    # Create the aqm.rc file in the specified run directory.
    #
    #-----------------------------------------------------------------------
    #
    print_info_msg(f'''
        Creating the aqm.rc file (\"{AQM_RC_FN}\") in the specified
        run directory (run_dir):
          run_dir = \"{run_dir}\"''', verbose=VERBOSE)
    #
    # Set output file path
    #
    aqm_rc_fp=os.path.join(run_dir,AQM_RC_FN)
    #
    # Extract from cdate the starting year, month, and day of the forecast.
    #
    yyyy=cdate.year
    mm=cdate.month
    dd=cdate.day
    yyyymmdd=yyyy+mm+dd
    #
    # Set parameters in the aqm.rc file.
    #
    aqm_rc_bio_file_fp=os.path.join(AQM_BIO_DIR, AQM_BIO_FILE)
    aqm_fire_file_fn=AQM_FIRE_FILE+"_"+yyyymmdd+AQM_FIRE_FILE_SUFFIX
    aqm_rc_fire_file_fp=os.path.join(AQM_FIRE_DIR,yyyymmdd,aqm_fire_file_fn)
    #
    #-----------------------------------------------------------------------
    #
    # Create a multiline variable that consists of a yaml-compliant string
    # specifying the values that the jinja variables in the template 
    # AQM_RC_TMPL_FN file should be set to.
    #
    #-----------------------------------------------------------------------
    #
    settings = {
      'aqm_config_dir': AQM_CONFIG_DIR,
      'init_concentrations': init_concentrations,
      'aqm_rc_bio_file_fp': aqm_rc_bio_file_fp,
      'aqm_bio_dir': AQM_BIO_DIR,
      'aqm_rc_fire_file_fp': aqm_rc_fire_file_fp,
      'aqm_rc_fire_frequency': AQM_RC_FIRE_FREQUENCY
    }
    settings_str = cfg_to_yaml_str(settings)
    
    print_info_msg(dedent(f'''
        The variable \"settings\" specifying values to be used in the \"{AQM_RC_FN}\"
        file has been set as follows:
        #-----------------------------------------------------------------------
        settings =\n''') + settings_str,verbose=VERBOSE)
    #
    #-----------------------------------------------------------------------
    #
    # Call a python script to generate the experiment's actual AQM_RC_FN
    # file from the template file.
    #
    #-----------------------------------------------------------------------
    #
    try:
        fill_jinja_template(["-q", "-u", settings_str, "-t", AQM_RC_TMPL_FP, "-o", aqm_rc_fp])
    except:
        print_err_msg_exit(f'''
            Call to python script fill_jinja_template.py to create a \"{AQM_RC_FN}\"
            file from a jinja2 template failed.  Parameters passed to this script are:
              Full path to template aqm.rc file:
                AQM_RC_TMPL_FP = \"{AQM_RC_TMPL_FP}\"
              Full path to output aqm.rc file:
                aqm_rc_fp = \"{aqm_rc_fp}\"
              Namelist settings specified on command line:
                settings =
            {settings_str}''')
        return False

    return True

class Testing(unittest.TestCase):
    def test_create_model_configure_file(self):
        path = os.path.join(os.getenv('USHDIR'), "test_data")
        self.assertTrue(\
                create_aqm_rc_file( \
                      run_dir=path,
                      cdate=datetime(2021,1,1),
                      init_concentrations=True) )
    def setUp(self):
        USHDIR = os.path.dirname(os.path.abspath(__file__))
        AQM_RC_FN='aqm.rc'
        AQM_RC_TMPL_FP = os.path.join(USHDIR, "templates", AQM_RC_TMPL_FN)

        set_env_var('DEBUG',True)
        set_env_var('VERBOSE',True)
        set_env_var("USHDIR",USHDIR)
        set_env_var('AQM_RC_FN',AQM_RC_FN)
        set_env_var("AQM_RC_TMPL_FP",AQM_RC_TMPL_FP)
        set_env_var("AQM_CONFIG_DIR",AQM_CONFIG_DIR)
        set_env_var('init_concentrations',True)
        set_env_var("AQM_BIO_DIR",AQM_BIO_DIR)
        set_env_var('AQM_RC_FIRE_FREQUENCY',AQM_RC_FIRE_FREQUENCY)
