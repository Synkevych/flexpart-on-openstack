#!/usr/bin/env python3

from rm_folders import *
from db_connection import *
import logging

# single calculations that not in queue and not calculated now

def get_finished_series_and_calculations():
    try:
      connection = get_connection()
      cursor = connection.cursor()
      cursor.execute(
          "select distinct id_series, id_calc from journal where calc_type=3;")
      return cursor.fetchall()
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()

def remove_series_and_calculations_by_user():
    lists = get_finished_series_and_calculations()
    logging.info('Removing series and calculation by user ' + str(lists))
    for series_id, calc_id in lists:
        remove_folders('series', series_id)
        remove_folders('calculations', calc_id)


if __name__ == '__main__':
    remove_series_and_calculations_by_user()
