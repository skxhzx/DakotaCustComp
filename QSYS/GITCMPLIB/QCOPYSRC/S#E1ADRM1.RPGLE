      *===================================================================
      *
      *  Name .......... S#E1ADRM1
      *  Description ... SAP IDoc Central Address Seg Grp, Main Seg
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/14/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1adrm1       ds

     Dsap_e1adrm1                    10    inz('E2ADRM1001')
     D*                                    text('SAP Segment')
     Dsap_e1adrm1fill                53
     D*                                    text('Filler Field 01')
     Dsap_partner_q1                  3
     D*                                    text('Qualifier for Parner Func')
     Dsap_address_t1                  1
     D*                                    text('Address Type')
     Dsap_partner_id1                17
     D*                                    text('Partner no. SAP')
     D sap_jurisdic1                 17
     D*                                    text('Loc for Tax Calc')
     D sap_language1                  2
     D*                                    text('Language Key')
     D sap_formofadd1                15
     D*                                    text('Form of Address')
     D sap_name11                    40
     D*                                    text('Name or Address 1')
     D sap_name21                    40
     D*                                    text('Name or Address 2')
     D sap_name31                    40
     D*                                    text('Name or Address 3')
     D sap_name41                    40
     D*                                    text('Name or Address 4')
     D sap_name_text1                50
     D*                                    text('Name or Address Format')
     D sap_name_co1                  40
     D*                                    text('Subs Line for Name')
     D sap_location1                 40
     D*                                    text('Location Desc of Loc')
     D sap_building1                 10
     D*                                    text('Location Desc Building')
     D sap_floor1                    10
     D*                                    text('Location Floor')
     D sap_room1                     10
     D*                                    text('Location Room')
     D sap_street11                  40
     D*                                    text('House Num and Street')
     D sap_street21                  40
     D*                                    text('House Num and Street')
     D sap_street31                  40
     D*                                    text('House Num and Street')
     D sap_house_supl                 4
     D*                                    text('House Num')
     D sap_house_rang                10
     D*                                    text('House Num Interval')
     D sap_postl_cod1                10
     D*                                    text('Postal Code')
     D sap_postl_cod3                10
     D*                                    text('Postal Code')
     D sap_postl_area                15
     D*                                    text('Postal Deliv Dist')
     D sap_city1                     40
     D*                                    text('Town or City')
     D sap_city2                     40
     D*                                    text('Town or City')
     D sap_postl_pbox                10
     D*                                    text('PO Box')
     D sap_postl_cod2                10
     D*                                    text('Postal Code')
     D sap_postl_city                40
     D*                                    text('Town or City')
     D sap_telephone1                30
     D*                                    text('Telephone Number')
     D sap_telephone2                30
     D*                                    text('Telephone Number')
     D sap_telefax                   30
     D*                                    text('Fax Number')
     D sap_telex                     30
     D*                                    text('Telex Number')
     D sap_e_mail                    70
     D*                                    text('E-Mail Address')
     D sap_country1                   3
     D*                                    text('Country Indicator')
     D sap_country2                   3
     D*                                    text('Country Indicator')
     D sap_region                     3
     D*                                    text('Region or State')
     D sap_county_cod                 3
     D*                                    text('County Code')
     D sap_county_txt                25
     D*                                    text('County Name')
     D sap_tzcode                     6
     D*                                    text('Location Time Zone')
     D sap_tzdesc                    35
     D*                                    text('Location Time Zone')
     D*
