##import datetime package
from datetime import datetime as dt
format='%a %d %b %Y %H:%M:%S %z'
##timedelta function to get absolute value in second
for i in range(int(input())):
    print(int(abs((dt.strptime(input(), format) -
                   dt.strptime(input(),format)).total_seconds())))