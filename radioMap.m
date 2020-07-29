% 87.6 MHz [Faith FM]
% 90.9 MHz ABC NewsRadio – ABC – Future Service
% 93.3 MHz 2RPH – Radio for Print H/C – Future Service
% 94.1 MHz 2LIV (NineFourOne) – Christian Community
% 94.9 MHz Power FM Nowra – Grant Broadcasters
% 95.7 MHz ABC Classic – Classical Music
% 96.5 MHz 96.5 Wave FM – Grant Broadcasters
% 97.3 MHz ABC Illawarra – ABC
% 98.1 MHz i98FM – WIN Corporation
% 98.9 MHz Triple J – ABC
% 99.3 MHz 2MM – Relay of Sydney narrowcast Greek-language radio
% 99.7 MHz Mac FM – Macedonian language narrowcast
% 100.7 MHz Radio Hertz – Macedonian-language Radio
% 101.1 MHz Hot Country - Grant Broadcasters - Country Music Narrowcast Wollongong
% 103.7 MHz 2KY – Racing Radio
% 104.5 MHz 2UUU – Nowra community radio
% 105.3 MHz Hot Country - Grant Broadcasters - Country Music Narrowcast Wollongong
% 106.9 MHz VOX FM – Community radio
%

wollongong_keys = {  87.6 ,  90.9 ,  93.3 ,  94.1 ,  94.9 ,  95.7 ,  96.5 ,  97.3 ,  98.1 ,  98.9 ,  99.3 ,  99.7 ,  100.7 ,  101.1 ,  103.7 ,  104.5 ,  105.3 ,  106.9  };

wollongong_values = { 'Faith FM', 'ABC NewsRadio', '2RPH', '2LIV', 'Power FM', 'ABC Classic', 'Wave FM', 'ABC Illawarra', 'i98FM', 'Triple J', '2MM', 'MAC FM', 'Radio Hertz', 'Hot Country', '2KY Racing', '2UUU', 'Hot Country', 'VOX FM' };

radioContainer_woll = containers.Map(wollongong_keys, wollongong_values);


% Callsign	Location	Frequency (MHz)	Branding	Format	Type	Launch
% 2ABCFM	Sydney	92.9	ABC Classic FM 	Classical	National	24 January 1976
% 2SBSFM	Sydney	97.7	SBS Radio 	Multicultural	National	9 June 1975
% 2JJJ	Sydney	105.7	Triple J 	Youth	National	19 January 1975
% 2MAC	Campbelltown	91.3	C91.3	Hot AC	Commercial	2001
% 2PTV	Sydney	95.3	Smooth FM 95.3 	Adult Contemporary	Commercial	1 August 2005
% 2ONE	Katoomba	96.1	The Edge 96.1 	Rhythmic Contemporary	Commercial	7 September 1935 (as 2KA) 23 October 1992 (as One FM)
% 2SYD	Sydney	96.9	Nova 96.9 	Pop Contemporary Hit Radio	Commercial	2001
% 2UUS	Sydney	101.7	WSFM 101.7 	Classic Hits	Commercial	23 November 1978
% 2DAY	Sydney	104.1	2Day FM 	Pop Contemporary Hit Radio	Commercial	2 August 1980
% 2MMM	Sydney	104.9	Triple M 104.9 	Rock	Commercial	2 August 1980
% 2WFM	Sydney	106.5	KIIS 1065 	Pop Contemporary Hit Radio	Commercial	13 February 1925 (as 2UW) 30 April 1994 (as Mix 106.5) 19 January 2014 (as KIIS 106.5)
% 2RDJ	Burwood, New South Wales	88.1	2RDJ	Community Radio	Community	5 November 1983
% 2RRR	Ryde	88.5	2RRR	Community Radio	Community	1984
% 2MWM	Manly North	88.7	Radio Northern Beaches	Community Radio	Community	March 1984
% 2RSR	Sydney	88.9	Radio Skid Row	Community Radio	Community	10 August 1983
% 2GLF	Liverpool	89.3	89.3 2GLF	Community Radio	Community	1985
% 2RES	Waverley	89.7	Eastside Radio	Community Radio	Community	1983
% 2VTR	Windsor	89.9	Hawkesbury Radio	Community Radio	Community	1978
% 2NBC	Narwee	90.1	2NBC Radio	Community Radio	Community	May 1983
% 2CCR	Parramatta	90.5	Alive 90.5	Community Radio	Community	18 December 1992
% 2MFM	Sydney	92.1	Muslim Community Radio 	Muslim Community Radio	Community	1995
% 2LND	Sydney	93.7	Koori Radio 	Indigenous programming	Community	December 2002
% 2FBI	Sydney	94.5	FBi Radio 	Australian Music	Community	29 August 2003
% 2OOO	Sydney	98.5	2000 FM	Multilingual	Community	1994
% 2NSB	Chatswood	99.3	Northside Radio	Community Radio	Community	May 1983
% 2SSR	Sutherland	99.7	2SSR	Community Radio	Community	26 September 1992
% 2SWR	Blacktown	99.9	SWR FM	Community Radio	Community	27 September 2003
% 2HHH	Hornsby	100.1	Triple H 100.1	Community Radio	Community	2000
% 2MCR	Campbelltown	100.3	2MCR	Community Radio	Community	22 August 1989
% 2RPH	Sydney East	100.5	RPH Print Radio	Radio Reading Service	Community	18 April 1983
% 2WOW	Penrith	100.7	Wow FM	Community Radio	Community	June 2001
% 2BAC	2BACR	100.9	BFM 100.9	Community Radio	Community	1983
% 2MBS	Sydney	102.5	Fine Music Sydney 	Classical/Jazz/Blues	Community	15 December 1974
% 2CBA	Sydney	103.2	Hope 103.2	Contemporary Christian	Community	5 March 1979
% 2SER	Sydney	107.3	2SER 	Community Radio	Community	1 October 1979
%   Sydney	87.6	Mood FM		Narrowcast
%   Brookvale	87.6	Raw FM	Dance	Narrowcast	December 1999
%   Penrith	87.8	The Beat	80's Music	Narrowcast	2 March 2020
%   Penrith / Camden	88.0 / 88.7	Vintage FM	Oldies	Narrowcast	1 January 2009
%   Sydney	87.8	Radio Austral	Spanish	Narrowcast	27 June 1992
%   Bondi	88.0	Bondi FM		Narrowcast


sydney_keys = { 92.9, 97.7, 105.7, 91.3,   95.3,    96.1,    96.9,    101.7,   104.1,   104.9,    106.5,    88.1,    88.5,    88.7,    88.9,    89.3,    89.7,    89.9,    90.1,    90.5,    92.1,    93.7,    94.5,    98.5,    99.3,    99.7,    99.9,    100.1,    100.3,    100.5,    100.7,    100.9,    102.5,    103.2,    107.3,    87.6,    87.6,    87.8,    88.0,    88.7,    87.8,    88   };
sydney_values = { 'ABC Classic FM','SBS Radio', 'Triple J', 'C91.3','Smooth FM 95.3 ','The Edge 96.1 ','Nova 96.9 ','WSFM 101.7 ','2Day FM ', 'Triple M 104.9 ','KIIS 1065 ','2RDJ','2RRR','Radio Northern Beaches','Radio Skid Row','89.3 2GLF','Eastside Radio','Hawkesbury Radio','2NBC Radio','Alive 90.5','Muslim Community Radio','Koori Radio','FBi Radio ','2000 FM','Northside Radio','2SSR','SWR FM','Triple H 100.1','2MCR','RPH Print Radio','Wow FM','BFM 100.9','Fine Music Sydney','Hope 103.2','2SER ','Mood FM','Raw FM','The Beat','Vintage FM','VintageFM','Radio Austral','Bondi FM' };

radioContainer_syd = containers.Map(sydney_keys, sydney_values);


