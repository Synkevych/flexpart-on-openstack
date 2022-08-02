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
        return database
    else:
        raise Exception(
            'Section {0} not found in the {1} file'.format(section, filename))



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

def perform_request(query, series_id=False, update=False):
    try:
      connection = get_connection()
      cursor = connection.cursor()
      if series_id:
          cursor.execute(query, (series_id,))
          return cursor.fetchone()
      elif series_id & update:
          cursor.execute(query, (series_id,))
          logging.info('Calculation type ' + str(series_id) + ' updated')
          connection.commit()
      else:
          cursor.execute(query)
          return cursor.fetchall()
      # if cursor.fetchall() == 0: remove folders
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()
