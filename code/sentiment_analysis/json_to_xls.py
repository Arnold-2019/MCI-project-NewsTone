import openpyxl
import pandas as pd

def convert():
    df=pd.read_json('./json/2020-titles.json')
    df.to_excel('./xlsx/2020-titles.xlsx')

if __name__ == '__main__':
    convert()
