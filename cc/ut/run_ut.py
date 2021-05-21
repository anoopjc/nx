import sys
import os
from pprint import pprint
from StringIO import StringIO
import unittest


SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
# NOTE: Provide correct path
MAIN_PJT_PATH="/Volumes/src/ubvm-main"


def load_py_paths():
    """
    dynamically load all the .egg files.
    Put all your .egg files in a directory named "eggs".
    Following code will add all of them to sys.path,
    so that you can import from those .egg files directly.
    """
    EGG_DIR = os.path.join(MAIN_PJT_PATH, "devtools/devtool-master/.python/lib/python2.7/site-packages/")
    sys.path.insert(0, os.path.join(MAIN_PJT_PATH, "infra_client/.python"))
    sys.path.insert(0, os.path.join(MAIN_PJT_PATH, "builds/build-master-opt-clang-shlib-infra/.python"))
    sys.path.insert(0, os.path.join(MAIN_PJT_PATH, "infra_server/.python"))
    for filename in os.listdir(EGG_DIR):
        if filename.endswith(".egg"):
            sys.path.insert(0, EGG_DIR + filename)

    pprint(sys.path)


def run_ut():
    # NOTE: Change to ut file
    py_test_path=os.path.join(MAIN_PJT_PATH, "infra_server/cluster/pytest/genesis/convert_cluster/vm_migration_test.py")
    py_test_file=os.path.basename(os.path.normpath('{}'.format(py_test_path)))
    py_test_file_link_path=os.path.join(SCRIPT_DIR, py_test_file)

    # create symlink
    cmd="ln -s {} {}".format(py_test_path, py_test_file_link_path)
    os.system(cmd)
    # running UT Class
    stream = StringIO()
    runner = unittest.TextTestRunner(stream=stream)
    # NOTE: Change to needed Test Class
    from vm_migration_test import VmMigrationManagerTest
    #result = runner.run(unittest.makeSuite(VmMigrationManagerTest.test_poweroff_uvm))
    result = runner.run(unittest.makeSuite(VmMigrationManagerTest))
    # remove symlink
    os.system("rm {}".format(py_test_file_link_path))
    # also remove the pyc file
    os.system("rm {}c".format(py_test_file_link_path))
    print 'Tests run ', result.testsRun
    print 'Errors ', result.errors
    pprint(result.failures)
    stream.seek(0)
    print 'Test output\n', stream.read()



def main():
    # Add all required py_paths
    load_py_paths()
    print("-"*80)
    os.system("pwd")
    # run ut class; details of testcase add in this fn
    run_ut()


if __name__ == '__main__':
    main()
