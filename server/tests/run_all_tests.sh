#!/bin/bash

# tells the server to use the local database, not the production one
export GRAFFITI_DB=postgresql://localhost/mydb

# python auth_api_test.py
# python user_api_test.py
python post_api_test.py
# python post_test.py
# python user_test.py
# python userpost_test.py
