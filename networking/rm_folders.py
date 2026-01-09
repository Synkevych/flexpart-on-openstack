#!/usr/bin/env python3

import os, shutil, logging

home_dir=os.getcwd()
logging.basicConfig(filename="main.log", level=logging.INFO,
                    format="%(asctime)s %(message)s")

def remove_folders(type, id):
    parent_folder_path = home_dir + '/' + type + '/'
    path_to_dir = os.path.join(parent_folder_path + str(id))
    if os.path.isdir(path_to_dir):
      shutil.rmtree(path_to_dir)
      print('Folder ', path_to_dir, ' removed')
      logging.info('Folder ' + str(path_to_dir) + ' removed')
