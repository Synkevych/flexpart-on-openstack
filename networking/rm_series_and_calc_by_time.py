#!/usr/bin/env python3

import psycopg2
from psycopg2 import Error
from rm_folders import *
from db_connection import *
import logging

logging.basicConfig(filename="main.log", level=logging.INFO,
                   format="%(asctime)s %(message)s")

def get_old_series(max_calc_time):
    try:
      connection = get_connection()
      cursor = connection.cursor()
      select_query = """select distinct id_series from journal where DATE_PART(\'day\', NOW() - date_calc) >= %s;"""
      cursor.execute(select_query, (max_calc_time,))
      return cursor.fetchall()
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()


def count_finished_calculations_in_series(series_id):
    try:
      connection = get_connection()
      cursor = connection.cursor()
      query = """select count(id_calc) from journal where id_series=%s and (calc_yes=0 or calc_yes=5);"""
      cursor.execute(query, (series_id,))
      return cursor.fetchone()
      # if cursor.fetchall() == 0: remove folders
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()


def get_calculations_ids(series_id):
    try:
      connection = get_connection()
      cursor = connection.cursor()
      select_query = """select id_calc from journal where id_series = %s;"""
      cursor.execute(select_query, (series_id,))
      return cursor.fetchall()
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()


def update_calc_type(series_id):
    try:
      connection = get_connection()
      cursor = connection.cursor()
      query = """update journal set calc_type=3 where id_series=%s;"""
      cursor.execute(query, (series_id,))
      logging.info('Calculation type ' + str(series_id) + ' updated')
      connection.commit()
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()


def remove_series_and_calculations_by_time():
    max_calc_time = 7
    # return an array of lists, or a list
    series_ids = get_old_series(max_calc_time)
    logging.info('Series to remove by time ' + str(series_ids))
    print('Series ids that are older than', max_calc_time, 'days', series_ids)

    for series_id in series_ids:
        calculation_finished = count_finished_calculations_in_series(series_id) # 0 == finished
        print('Calculation in series', series_id[0], 'completed ?', calculation_finished[0] == False)

        if calculation_finished[0] == False:
           remove_folders('series', series_id[0])
           calc_ids = get_calculations_ids(series_id)
           logging.info('Calculations to remove ' + str(calc_ids))
           for calc_id in calc_ids:
               remove_folders('calculations', calc_id[0])
           update_calc_type(series_id[0])  # update calc_type=3


if __name__ == '__main__':
    remove_series_and_calculations_by_time()
