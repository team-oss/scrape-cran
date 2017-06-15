import pandas as pd
import datetime

categories = ['Audio and Video', 'Business and Enterprise', 'Communications', 'Development', 'Games', 'Graphics', 'Home and Education', 'Science and Engineering', 'Security and Utilities', 'System Administration']
times = [datetime.datetime(year = 2016, month = 10, day = 12, hour = 23, minute = 18), 
         datetime.datetime(year = 2016, month = 10, day = 12, hour = 22, minute = 56), 
         datetime.datetime(year = 2016, month = 10, day = 13, hour = 8, minute = 37), 
         datetime.datetime(year = 2016, month = 10, day = 13, hour = 8, minute = 52), 
         datetime.datetime(year = 2016, month = 10, day = 13, hour = 9, minute = 36), 
         datetime.datetime(year = 2016, month = 10, day = 13, hour = 13, minute = 28), 
         datetime.datetime(year = 2016, month = 10, day = 13, hour = 9, minute = 10), 
         datetime.datetime(year = 2016, month = 10, day = 12, hour = 8, minute = 47), 
         datetime.datetime(year = 2016, month = 10, day = 13, hour = 13, minute = 42), 
         datetime.datetime(year = 2016, month = 10, day = 14, hour = 8, minute = 13)]

df = pd.read_csv('SourceForge Data.csv')
df['last_update_days_ago'] = -1
df['last_update_hours_ago'] = -1
df['last_update_date'] = -1
for i in range(len(df)):
    time = times[categories.index(df['Category'][i])]
    if 'day' in df.last_update[i]:
        df.last_update_days_ago[i] = int(df.last_update[i].split()[0])
        df.last_update_hours_ago[i] = int(time.hour)+(df.last_update_days_ago[i]-1)*24
        temptime = time - datetime.timedelta(days = df.last_update_days_ago[i])
        df.last_update_date[i] = str(temptime.year)+'-'+str(temptime.month)+'-'+str(temptime.day)
    else:
        if 'hour' in df.last_update[i]:
            df.last_update_hours_ago[i] = int(df.last_update[i].split()[0])
            last_update_days_ago = int(time.hour)-(df.last_update_hours_ago[i])
            if last_update_days_ago > 0:
                df.last_update_days_ago[i] = 0
            else:
                df.last_update_days_ago[i] = 1
            temptime = time - datetime.timedelta(hours = df.last_update_hours_ago[i])
            df.last_update_date[i] = str(temptime.year)+'-'+str(temptime.month)+'-'+str(temptime.day)
        else:
            if 'minute' in df.last_update[i]:  
                df.last_update_hours_ago[i] = 1
                df.last_update_days_ago[i] = 0
                df.last_update_date[i] = str(time.year)+'-'+str(time.month)+'-'+str(time.day)
            else:
                if 'decade' in df.last_update[i]:  
                    df.last_update_days_ago[i] = int(df.last_update[i].split()[0])*3650
                    df.last_update_hours_ago[i] = df.last_update_days_ago[i]*24
                    df.last_update_date[i] = str(int(time.year)-int(df.last_update[i].split()[0])*10)+'-'+str(time.month)+'-'+str(time.day)
                else:
                    df.last_update_date[i] = df.last_update[i]
                    dt = datetime.datetime(year = int(df.last_update[i].split('-')[0]), month = int(df.last_update[i].split('-')[1]), day = int(df.last_update[i].split('-')[2]))
                    df.last_update_days_ago[i] = int((time - dt).days)
                    df.last_update_hours_ago[i] = df.last_update_days_ago[i]*24
    print(float(i*100)/float(len(df)))

df.to_csv('SourceForge Data Clean.csv')

