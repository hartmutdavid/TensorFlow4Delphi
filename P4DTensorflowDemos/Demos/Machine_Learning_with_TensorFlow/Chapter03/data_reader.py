import csv
import time

# 
# crime14_freq = data_reader.read('crimes_2014.csv', 1, '%d-%b-%y %H:%M:%S', 2014)
# freq = read('311.csv', 0, '%m/%d/%Y', 2014)

def read(filename, date_idx, date_parse, year, bucket=7):

    days_in_year = 365

    # Create initial frequency map
    freq = {}
    for period in range(0, int(days_in_year/bucket)):
        freq[period] = 0

    # Read data and aggregate crimes per day
    with open(filename, 'rb') as csvfile:
        csvreader = csv.reader(csvfile)
        csvreader.next()
        for row in csvreader:
            if row[date_idx] == '':
                continue
            t = time.strptime(row[date_idx], date_parse)
            if t.tm_year == year and t.tm_yday < (days_in_year-1):
                freq[int(t.tm_yday / bucket)] += 1

    return freq

if __name__ == '__main__':
    freq = read('311.csv', 0, '%m/%d/%Y', 2014)
    print freq