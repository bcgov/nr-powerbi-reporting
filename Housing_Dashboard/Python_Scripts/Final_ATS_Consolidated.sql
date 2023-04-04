SELECT 'FOR' ministry_code
     , authorizations.business_area
     , 'ATS' source_system_acronym
     , authorizations.permit_type
     , projects.project_id project_id
     , authorizations.AUTHORIZATION_ID application_id
     , projects.project_name
     , projects.project_description
     , projects.project_location
     , NULL utm_easting
     , NULL utm_northing
     , authorizations.RECEIVED_DATE 
     , authorizations.ACCEPTED_DATE 
     , NULL adjudication_date 
     , authorizations.rejected_date
     , authorizations.AMENDMENT_RENEWAL_DATE
     , authorizations.TECH_REVIEW_COMPLETION_DATE
     , authorizations.fn_consultn_start_date
     , authorizations.fn_consultn_completion_date
     , NULL fn_consultn_comment
     , projects.region_name
     , CASE  
       SUBSTR(projects.project_description
             , INSTR(projects.project_description,',',1,2)+1 
             , INSTR(projects.project_description,',',1,3) - 
                  INSTR(projects.project_description,',',1,2)-1 
             ) 
       WHEN 'IL' THEN 'Y'
       WHEN 'Not_IL' THEN 'N'             
       ELSE 'Unknown' END indigenous_led_ind
     , CASE  
       SUBSTR(projects.project_description
             , INSTR(projects.project_description,',',1,3)+1 
             , INSTR(projects.project_description,',',1,4) - 
                  INSTR(projects.project_description,',',1,3)-1 
             ) 
       WHEN 'Rental' THEN 'Y'
       WHEN 'Not_Rental' THEN 'N'
       ELSE 'Unknown' END rental_license_ind      
     , CASE  
       SUBSTR(projects.project_description
             , INSTR(projects.project_description,',',1,1)+1 
             , INSTR(projects.project_description,',',1,2) - 
                  INSTR(projects.project_description,',',1,1)-1 
             ) 
       WHEN 'SH' THEN 'Y'
       WHEN 'Not_SH' THEN 'N'             
       ELSE 'Unknown' END social_housing_ind
     , REPLACE(
         REPLACE(
           REPLACE(
             REPLACE(SUBSTR(projects.project_description,1,INSTR(projects.project_description,',')-1) 
                   , 'Unknown_Units'
                   , NULL)
             , 'SF_','Single-Family ')
           , 'SF', 'Single-Family'  )
         , 'MF_','Multi-Family ') housing_type
     , REPLACE(
       SUBSTR(projects.project_description
             , INSTR(projects.project_description,',',1,4)+1 
             , INSTR(projects.project_description,',',1,5) - 
                  INSTR(projects.project_description,',',1,4)-1 
             ) , 'Unknown', NULL) estimated_housing
     , NULL application_status
  FROM (				     
SELECT prj.PROJECT_ID 
     , prj.PROJECT_NAME
     , REPLACE(REPLACE(prj.DESCRIPTION,CHR(10),NULL),CHR(13),NULL) project_description 
     , REPLACE(REPLACE(prj.LOCATION,CHR(10),NULL),CHR(13),NULL) project_location
     , psc.NAME project_status
     , ptc.NAME project_type
     , amfr.REGION_NAME
     , aso.SUBREGIONAL_OFFICE_NAME
     , aso2.SECONDARY_OFFICE_NAME
     , prj.WHO_CREATED
     , prj.WHEN_CREATED
     , prj.WHO_UPDATED
     , prj.WHEN_UPDATED  
  FROM ats.ATS_PROJECTS prj
     , ats.ATS_PROJ_PROJ_TYPE_CODE_XREF pt
     , ats.ATS_PROJECT_STATUS_CODES psc
     , ats.ATS_PROJECT_TYPE_CODES ptc
     , ats.ATS_MANAGING_FCBC_REGIONS amfr
     , ats.ATS_SUBREGIONAL_OFFICES aso
     , ats.ATS_SECONDARY_OFFICES aso2
 WHERE prj.PROJECT_ID = pt.project_id
   AND pt.PROJECT_TYPE_CODE = ptc.PROJECT_TYPE_CODE
   AND prj.PROJECT_STATUS_CODE = psc.PROJECT_STATUS_CODE
   AND prj.MANAGING_FCBC_REGION_ID = AMFR.MANAGING_FCBC_REGION_ID
   AND prj.SUBREGIONAL_OFFICE_ID = aso.SUBREGIONAL_OFFICE_ID
   AND prj.SECONDARY_OFFICE_ID = aso2.SECONDARY_OFFICE_ID(+)
   AND prj.PROJECT_STATUS_CODE = 1 
   AND pt.PROJECT_TYPE_CODE = 681) projects
     , (SELECT auth.PROJECT_ID 
     , auth.AUTHORIZATION_ID
     , aai.AUTHORIZATION_INSTRUMENT_NAME permit_type
     , apa.AGENCY_NAME business_area
     , auth.APPLICATION_ACCEPTED_DATE  accepted_date
     , auth.APPLICATION_RECEIVED_DATE  received_date
     , auth.application_rejected_date  rejected_date
     , auth.AUTHORIZATION_DUE_DATE
     , auth.AMENDMENT_RENEWAL_DATE 
     , auth.target_days
     , auth.TECH_REVIEW_COMPLETION_DATE 
     , auth.FIRST_NATION_START_DATE fn_consultn_start_date
     , auth.FIRST_NATION_COMPLETION_DATE fn_consultn_completion_date
     , auth.FIRST_NATION_COMMENT fn_consultn_comment
     , auth.ADJUDICATION_DATE 
     , aasc.NAME auth_status
     , aasc.AUTHORIZATION_STATUS_CODE AUTHORIZATION_STATUS_CODE
     , AACRC.NAME close_reason
  FROM ATS_AUTHORIZATIONS auth
     , ats.ATS_AUTHORIZATION_STATUS_CODES aasc 
     , ats.ATS_ATHN_CLOSE_REASON_CODES aacrc 
     , ats.ATS_MANAGING_FCBC_REGIONS amfr 
     , ats.ATS_REGIONAL_USERS aru 
     , ats.ATS_AUTHORIZATION_INSTRUMENTS aai 
     , ats.ATS_PARTNER_AGENCIES apa 
 WHERE auth.AUTHORIZATION_STATUS_CODE = aasc.AUTHORIZATION_STATUS_CODE (+) 
   AND auth.ATHN_CLOSE_REASON_CODE = aacrc.ATHN_CLOSE_REASON_CODE (+)
   AND auth.managing_fcbc_region_id = AMFr.MANAGING_FCBC_REGION_ID (+)
   AND auth.REGIONAL_USER_ID = aru.REGIONAL_USER_ID (+)
   AND auth.AUTHORIZATION_INSTRUMENT_ID = aai.AUTHORIZATION_INSTRUMENT_ID(+)
   AND aai.PARTNER_AGENCY_ID = apa.PARTNER_AGENCY_ID 
   AND aasc.AUTHORIZATION_STATUS_CODE = 1
) authorizations
WHERE projects.project_id = authorizations.project_id
ORDER BY 5