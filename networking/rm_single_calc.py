from rm_folders import *
from db_connection import *
import logging


def get_finished_notqueued_calculations():
    try:
      connection = get_connection()
      cursor = connection.cursor()
      cursor.execute(
          "select id_series, id_calc from journal where calc_type=0 and calc_yes!=0 and calc_yes!=5")
      return cursor.fetchall()
    except(Exception, Error) as error:
      print("Error while connecting to PostgreSQL", error)
    finally:
      if connection is not None:
          connection.close()


def remove_single_calculations():
    lists = get_finished_notqueued_calculations()
    print('series, calculations ', lists)
    logging.info(
        'Removing finished and not queued series and calculation ' + str(lists))
    for series_id, calc_id in lists:
        remove_folders('series', series_id)
        remove_folders('calculations', calc_id)


if __name__ == '__main__':
    remove_single_calculations()
