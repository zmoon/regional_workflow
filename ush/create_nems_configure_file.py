#!/usr/bin/env python3

import os
import unittest
from datetime import datetime
from textwrap import dedent

from python_utils import import_vars, set_env_var, print_input_args, \
                         print_info_msg, print_err_msg_exit, lowercase, cfg_to_yaml_str

from fill_jinja_template import fill_jinja_template

def create_nems_configure_file(run_dir):
    """ Creates a nems configuration file in the specified
    run directory

    Args:
        run_dir: run directory
    Returns:
        Boolean
    """

    print_input_args(locals())

    #import all environment variables
    import_vars()
    
    #
    #-----------------------------------------------------------------------
    #
    # Create the NEMS configuration file in the specified run directory.
    #
    #-----------------------------------------------------------------------
    #
    print_info_msg(f'''
        Creating the nems.configure file in the specified run directory (run_dir):
          run_dir = \"{run_dir}\"''', verbose=VERBOSE)
    #
    # Set output file path
    #
    nems_config_fp=os.path.join(run_dir,"nems.configure")
    #
    #-----------------------------------------------------------------------
    #
    # Create a multiline variable that consists of a yaml-compliant string
    # specifying the values that the jinja variables in the template 
    # model_configure file should be set to.
    #
    #-----------------------------------------------------------------------
    #
    settings = {
      'dt_atmos': DT_ATMOS,
      'print_esmf': PRINT_ESMF,
      'cpl_aqm': CPL_AQM
    }
    settings_str = cfg_to_yaml_str(settings)
    
    print_info_msg(dedent(f'''
        The variable \"settings\" specifying values to be used in the nems.configure
        file has been set as follows:
        #-----------------------------------------------------------------------
        settings =\n''') + settings_str,verbose=VERBOSE)
    #
    #-----------------------------------------------------------------------
    #
    # Call a python script to generate the experiment's actual MODEL_CONFIG_FN
    # file from the template file.
    #
    #-----------------------------------------------------------------------
    #
    try:
        fill_jinja_template(["-q", "-u", settings_str, "-t", NEMS_CONFIG_TMPL_FP, "-o", nems_config_fp])
    except:
        print_err_msg_exit(f'''
            Call to python script fill_jinja_template.py to create the nems.configure
            file from a jinja2 template failed.  Parameters passed to this script are:
              Full path to template nems.configure file:
                NEMS_CONFIG_TMPL_FP = \"{NEMS_CONFIG_TMPL_FP}\"
              Full path to output nems.configure file:
                nems_config_fp = \"{nems_config_fp}\"
              Namelist settings specified on command line:
                settings =
            {settings_str}''')
        return False

    return True

class Testing(unittest.TestCase):
    def test_create_nems_configure_file(self):
        path = os.path.join(os.getenv('USHDIR'), "test_data")
        self.assertTrue(create_nems_configure_file(run_dir=path))
    def setUp(self):
        USHDIR = os.path.dirname(os.path.abspath(__file__))
        NEMS_CONFIG_FN='nems.configure'
        NEMS_CONFIG_TMPL_FP = os.path.join(USHDIR, "templates", NEMS_CONFIG_TMPL_FN)
        set_env_var('DEBUG',True)
        set_env_var('VERBOSE',True)
        set_env_var("USHDIR",USHDIR)
        set_env_var('NEMS_CONFIG_FN',NEMS_CONFIG_FN)
        set_env_var("NEMS_CONFIG_TMPL_FP",NEMS_CONFIG_TMPL_FP)
        set_env_var('DT_ATMOS',1)
        set_env_var('PRINT_ESMF',True)
        set_env_var('CPL_AQM',True)