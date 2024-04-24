# import sys
# print(sys.path)  # Print out PYTHONPATH
# from app.models.database import Base
# print(Base.__file__)  # Print out the path of the imported module

import os
print("Current Directory:", os.getcwd())

import sys
print("PYTHONPATH:", sys.path)

from models.database import Base
print(Base.__file__)  # Print out the path of the imported module
