import psycopg2
from psycopg2 import Error
from configparser import ConfigParser

db_connection = {}

def db_config(filename='database.ini', section='postgresql'):
    parser = ConfigParser()
    parser.read(filename)

    database = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            database[param[0]] = param[1]
    else:
        raise Exception(
            'Section {0} not found in the {1} file'.format(section, filename))

    return database


def get_connection():
    connection = None
    try:
        params = db_config()
        connection = psycopg2.connect(**params)
        return connection
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

def close_connection(connection):
    if connection:
        connection.close()
        print("Postgres connection is closed")
