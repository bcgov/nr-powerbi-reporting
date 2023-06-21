SELECT projects.project_id project_id
     , authorizations.AUTHORIZATION_ID
     , CASE WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (961,120,1141,76,741,742,581,742,582,744,743,583,1061) 
       		THEN 'EMLI'
     		WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (69,542,1481,1121,1124,1125,1122,421,68,541,70,1,71,124
     		                                                   	,181,73,701,702,33,704,503,82,482,710,709,1241,481
     															,483,502,716,708,80,39,686,685,132,84,711,684,41,110
     															,29,714,102,105,717,521,524,103,501,718,18,720,281,89
     															,25,24,3,4,683,713,1101,1402,1401,57,44,1201,45,48,851
     															,50,941,99,51,852,58,981,52,1081,1083,1082,56,1001,401
     															,65,881,861,846,841,843,842,847,845,441,921,11,66,100
     															,72,761,341,901,27,762,10,1181,113,1022,1021,119,126
     															,28,30,1023,1261,641,16,1041,721 ) 
     		THEN 'FOR'
     		WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (2,20,682,19,1421,1441) 
     		THEN 'AGR'     	
     		WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (1282,1281,1343,1344,1361,1301,1302,1303
     		                                                    ,1304,1283,60,1341,1305,1306,1342,21,107) 
     		THEN 'ENV'       	
       END AS Ministry
     , CASE WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (961,120,1141,76,741,742,581,742,582,744,743,583,1061) 
            THEN 'Mines'
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (69,542,1481,1121,1124,1125,1122,421,68,541,70,1,71,124) 
            THEN 'Water'
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (181,73,701,702,33,704,503,82,482,710,709,1241,481
                                                                ,483,502,716,708,80,39,686,685,132,84,711,684,41,110
                                                                ,29,714,102,105,717,521,524,103,501,718,18,720,281,89
                                                                ,25,24,3,4,683,713) 
            THEN 'Lands'
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (1101,1402,1401,57,44,1201,45,48,851,50,941,99,51
                                                               ,852,58,981,52,1081,1083,1082,56,1001,401,65,881,861
                                                               ,846,841,843,842,847,845,441,921,11,66,100,72) 
            THEN 'Fish and Wildlife' 
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (2,20,682,19,1421,1441) 
            THEN 'Agriculture'     
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (761,341,901,27,762,10,1181,113,1022,1021
                                                               ,119,126,28,30,1023,1261,641,16,1041,721) 
            THEN 'Forests'
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (1282,1281,1343,1344,1361,1301,1302,1303
                                                               ,1304,1283,60,1341,1305,1306,1342) 
            THEN 'Parks'     
            WHEN authorizations.AUTHORIZATION_INSTRUMENT_ID IN (21,107) 
            THEN 'Recreation Sites and Trails'  	
     END AS business_area
     , authorizations.authorization_type 
     , projects.project_location
     , authorizations.RECEIVED_DATE 
     , authorizations.ACCEPTED_DATE 
     , authorizations.rejected_date
     , authorizations.auth_status
     , projects.region_name
  FROM (				     
SELECT prj.PROJECT_ID
     , REPLACE(REPLACE(prj.LOCATION,CHR(10),NULL),CHR(13),NULL) project_location
     , amfr.REGION_NAME
  FROM ats.ATS_PROJECTS prj
     , ats.ATS_MANAGING_FCBC_REGIONS amfr
 WHERE prj.MANAGING_FCBC_REGION_ID = AMFR.MANAGING_FCBC_REGION_ID
   AND prj.PROJECT_STATUS_CODE = 1) projects
     , (SELECT auth.PROJECT_ID 
     , auth.AUTHORIZATION_ID
     , aai.AUTHORIZATION_INSTRUMENT_ID
     , aai.AUTHORIZATION_INSTRUMENT_NAME authorization_type
     , auth.APPLICATION_ACCEPTED_DATE  accepted_date
     , auth.APPLICATION_RECEIVED_DATE  received_date
     , auth.application_rejected_date  rejected_date
     , auth.ADJUDICATION_DATE 
     , aasc.NAME auth_status
     , aasc.AUTHORIZATION_STATUS_CODE
  FROM ATS_AUTHORIZATIONS auth
     , ats.ATS_AUTHORIZATION_STATUS_CODES aasc
     , ats.ATS_AUTHORIZATION_INSTRUMENTS aai 
 WHERE auth.AUTHORIZATION_STATUS_CODE = aasc.AUTHORIZATION_STATUS_CODE (+)
   AND auth.AUTHORIZATION_INSTRUMENT_ID = aai.AUTHORIZATION_INSTRUMENT_ID(+)
   AND aasc.AUTHORIZATION_STATUS_CODE <> 2 -- NOT Closed
   AND auth.AUTHORIZATION_INSTRUMENT_ID IN 
       (961,120,1141,76,741,742,581,742,582,744,743,583,1061,69,542,1481,1121,1124,1125,1122,421
       ,68,541,70,1,71,124,181,73,701,702,33,704,503,82,482,710,709,1241,481,483,502,716,708,80
       ,39,686,685,132,84,711,684,41,110,29,714,102,105,717,521,524,103,501,718,18,720,281,89,25
       ,24,3,4,683,713,1101,1402,1401,57,44,1201,45,48,851,50,941,99,51,852,58,981,52,1081,1083
       ,1082,56,1001,401,65,881,861,846,841,843,842,847,845,441,921,11,66,100,72,2,20,682,19,1421
       ,1441,761,341,901,27,762,10,1181,113,1022,1021,119,126,28,30,1023,1261,641,16,1041,721,1282
       ,1281,1343,1344,1361,1301,1302,1303,1304,1283,60,1341,1305,1306,1342,21,107)
) authorizations
WHERE projects.project_id = authorizations.project_id
ORDER BY 1, 2;