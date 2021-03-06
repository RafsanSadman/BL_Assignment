------------Select each MSISDN------------------------------------
SELECT MSISDN FROM SAD_TEST_IPDR

-------------Select Specific start and end datetime domain/app wise---------------------
select A.DOMAIN, MIN(A.START_TIME) START_DATETM, MAX(A.END_TIME) END_DATETM 
from SAD_TEST_IPDR A
GROUP BY A.DOMAIN

--------------Need to calculate first ST (start time), ET (End Time) for each FDR------------
select 
MSISDN, (to_char(END_TIME,'YYYYMMDDHH24MISS') - to_char(START_TIME,'YYYYMMDDHH24MISS')) FDR_DURATION from SAD_TEST_IPDR

---------------No of FDR COUNT--------------------------
select MSISDN, count(*) FDR_COUNT from SAD_TEST_IPDR
group by MSISDN

-------------then to calculate ET*(ET-10 min) for each FDR to exclude idle time (10 min) of each FDR--------------------
select END_TIME from SAD_TEST_IPDR
where to_char(END_TIME,'YYYYMMDDHH24MISS')=to_char(END_TIME,'YYYYMMDDHH24MISS')*(to_char(END_TIME,'YYYYMMDDHH24MISS') - 600)

-------------If ET-10 min < ST then keep the original ET=--------------------------------------
select * from SAD_TEST_IPDR
where to_char(START_TIME,'YYYYMMDDHH24MISS')>to_char(END_TIME,'YYYYMMDDHH24MISS') - 600

------Calculate Total volume of each call of each domain in Kb--------------------------------
select DOMAIN, SUM(ULVOLUME+DLVOLUME)/1024 TOT_VOLUME from SAD_TEST_IPDR
group by DOMAIN

------------------------Calculate Total time of each call of each VoIP App-----------------------


--------------------------Calculate bit rate(kbps) of each call of each VoIP App--------------------
SELECT MSISDN,TOT_DURATION,SUM(ULVOLUME+DLVOLUME)/1024 TOT_VOLUME FROM (
select 
MSISDN, (to_char(END_TIME,'YYYYMMDDHH24MISS') - to_char(START_TIME,'YYYYMMDDHH24MISS')) TOT_DURATION,ULVOLUME,DLVOLUME from SAD_TEST_IPDR)
GROUP BY MSISDN,TOT_DURATION

CREATE TABLE MSISDN_VS_KBPS AS 
SELECT MSISDN,TOT_DURATION,SUM(ULVOLUME+DLVOLUME)/1024 TOT_VOLUME FROM (
select 
MSISDN, (to_char(END_TIME,'YYYYMMDDHH24MISS') - to_char(START_TIME,'YYYYMMDDHH24MISS')) TOT_DURATION,ULVOLUME,DLVOLUME from SAD_TEST_IPDR)
GROUP BY MSISDN,TOT_DURATION

SELECT MSISDN,(TOT_VOLUME/NULLIF(TOT_DURATION,0)) AS BIT_RATE FROM MSISDN_VS_KBPS

---------------------Identification of Audio or video call and its count---------------------------------
--------AUDIO MISIDN WISE-----------
SELECT MSISDN,BIT_RATE FROM (SELECT MSISDN,(TOT_VOLUME/NULLIF(TOT_DURATION,0)) AS BIT_RATE FROM MSISDN_VS_KBPS)
WHERE BIT_RATE<=200

-------VIDEO MSISDN WISE------------
SELECT MSISDN,BIT_RATE FROM (SELECT MSISDN,(TOT_VOLUME/NULLIF(TOT_DURATION,0)) AS BIT_RATE FROM MSISDN_VS_KBPS)
WHERE BIT_RATE>200

----------VOIP APP----------------
CREATE TABLE DOMAIN_VS_KBPS AS 
SELECT DOMAIN,TOT_DURATION,SUM(ULVOLUME+DLVOLUME)/1024 TOT_VOLUME FROM (
select 
DOMAIN, (to_char(END_TIME,'YYYYMMDDHH24MISS') - to_char(START_TIME,'YYYYMMDDHH24MISS')) TOT_DURATION,ULVOLUME,DLVOLUME from SAD_TEST_IPDR)
GROUP BY DOMAIN,TOT_DURATION

SELECT DOMAIN,(TOT_VOLUME/TOT_DURATION) BITRATE FROM (
SELECT DOMAIN,SUM(TOT_DURATION) TOT_DURATION,SUM(TOT_VOLUME) TOT_VOLUME FROM DOMAIN_VS_KBPS
GROUP BY DOMAIN)

------VOIP AUDIO
SELECT DOMAIN,BIT_RATE FROM (SELECT DOMAIN,(TOT_VOLUME/TOT_DURATION) BIT_RATE FROM (
SELECT DOMAIN,SUM(TOT_DURATION) TOT_DURATION,SUM(TOT_VOLUME) TOT_VOLUME FROM DOMAIN_VS_KBPS
GROUP BY DOMAIN))
WHERE BIT_RATE<=200

------VOIP VIDEO
SELECT DOMAIN,BIT_RATE FROM (SELECT DOMAIN,(TOT_VOLUME/TOT_DURATION) BIT_RATE FROM (
SELECT DOMAIN,SUM(TOT_DURATION) TOT_DURATION,SUM(TOT_VOLUME) TOT_VOLUME FROM DOMAIN_VS_KBPS
GROUP BY DOMAIN))
WHERE BIT_RATE>200


