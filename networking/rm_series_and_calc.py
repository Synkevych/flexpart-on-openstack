#!/usr/bin/env python3

import psycopg2
from psycopg2 import Error
from rm_folders import *
from db_connection import *
import logging

logging.basicConfig(filename="main.log", level=logging.INFO,
                   format="%(asctime)s %(message)s")


def remove_series_and_calculations_by_time():
    # return an array of lists, or a list
    get_old_series = """select distinct id_series from journal where DATE_PART(\'day\', NOW() - date_calc) >= 7;"""
    series_ids = perform_request(get_old_series)
    logging.info('Series to remove by time ' + str(series_ids))
    print('Series ids that are older than 7 days', series_ids)

    if series_ids == None: return
    for series_id in series_ids:
        print('series id ', series_id[0])
        count_finished_calc_in_series = """select count(id_calc) from journal where id_series=%s and (calc_yes=0 or calc_yes=5);"""
        calculation_finished = perform_request(count_finished_calc_in_series, series_id[0]) # 0 == finished
        print('Calculation in series', series_id[0], 'completed ?', calculation_finished[0] == False)

        if calculation_finished[0] == 0:
           remove_folders('series', series_id[0])
           get_id_calc_query = """select id_calc from journal where id_series = %s;"""
           calc_ids = perform_request(get_id_calc_query, series_id[0])
           logging.info('Calculations to remove ' + str(calc_ids))
           for calc_id in calc_ids:
             remove_folders('calculations', calc_id)
           update_calc_type = """update journal set calc_type=3 where id_series=%s;"""
           perform_request(update_calc_type, series_id[0], True)  # update calc_type=3

# fix here check the calc_type=3 in all calculations
def remove_series_and_calculations_by_user():
    finished_series_and_calc = """select distinct id_series, id_calc from journal where calc_type=3;"""
    lists = perform_request(finished_series_and_calc)
    logging.info('Removing series and calculation by user ' + str(lists))
    for series_id, calc_id in lists:
        remove_folders('series', series_id)
        remove_folders('calculations', calc_id)


def remove_single_calculations():
    finished_single_calc = """select id_series, id_calc from journal where calc_type=0 and (calc_yes!=0 or calc_yes!=5)"""
    lists = perform_request(finished_single_calc)
    logging.info(
        'Removing finished and not queued series and calculation ' + str(lists))
    for series_id, calc_id in lists:
        remove_folders('series', series_id)
        remove_folders('calculations', calc_id)


if __name__ == '__main__':
    remove_series_and_calculations_by_time()
    remove_series_and_calculations_by_user()
    remove_single_calculations()
