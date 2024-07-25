      *===================================================================
      *
      *  Name .......... S#E1ADRM4
      *  Description ... SAP IDoc Central Address Seg Grp, Main Seg
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   03/12/12  RTR  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D s#e1adrm4       ds

     Dsap_e1adrm4                    10    inz('E2ADRM4001')
     D*                                    text('SAP Segment')
     Dsap_e1adrm4fill                53
     D*                                    text('Filler Field 01')
     Dsap_partner_q4                  3
     D*                                    text('Qualifier for Parner Func')
     Dsap_address_t4                  1
     D*                                    text('Address Type')
     Dsap_partner_id4                17
     D*                                    text('Partner no. SAP')
     Dsap_jurisdic4                  17
     D*                                    text('Loc for Tax Calc')
     Dsap_language4                   2
     D*                                    text('Language Key')
     Dsap_formofadd4                 15
     D*                                    text('Form of Address')
     Dsap_name14                     40
     D*                                    text('Name or Address 1')
     Dsap_name24                     40
     D*                                    text('Name or Address 2')
     Dsap_name34                     40
     D*                                    text('Name or Address 3')
     Dsap_name44                     40
     D*                                    text('Name or Address 4')
     Dsap_name_text4                 50
     D*                                    text('Name or Address Format')
     Dsap_name_co4                   40
     D*                                    text('Subs Line for Name')
     Dsap_location4                  40
     D*                                    text('Location Desc of Loc')
     Dsap_building4                  10
     D*                                    text('Location Desc Building')
     Dsap_floor4                     10
     D*                                    text('Location Floor')
     Dsap_room4                      10
     D*                                    text('Location Room')
     Dsap_street14                   40
     D*                                    text('House Num and Street')
     Dsap_street24                   40
     D*                                    text('House Num and Street')
     Dsap_street34                   40
     D*                                    text('House Num and Street')
     Dsap_house_supl4                 4
     D*                                    text('House Num')
     Dsap_house_rang4                10
     D*                                    text('House Num Interval')
     Dsap_postl_cod14                10
     D*                                    text('Postal Code')
     Dsap_postl_cod34                10
     D*                                    text('Postal Code')
     Dsap_postl_area4                15
     D*                                    text('Postal Deliv Dist')
     Dsap_city14                     40
     D*                                    text('Town or City')
     Dsap_city24                     40
     D*                                    text('Town or City')
     Dsap_postl_pbox4                10
     D*                                    text('PO Box')
     Dsap_postl_cod24                10
     D*                                    text('Postal Code')
     Dsap_postl_city4                40
     D*                                    text('Town or City')
     Dsap_telephone14                30
     D*                                    text('Telephone Number')
     Dsap_telephone24                30
     D*                                    text('Telephone Number')
     Dsap_telefax4                   30
     D*                                    text('Fax Number')
     Dsap_telex4                     30
     D*                                    text('Telex Number')
     Dsap_e_mail4                    70
     D*                                    text('E-Mail Address')
     Dsap_country14                   3
     D*                                    text('Country Indicator')
     Dsap_country24                   3
     D*                                    text('Country Indicator')
     Dsap_region4                     3
     D*                                    text('Region or State')
     Dsap_county_cod4                 3
     D*                                    text('County Code')
     Dsap_county_txt4                25
     D*                                    text('County Name')
     Dsap_tzcode4                     6
     D*                                    text('Location Time Zone')
     Dsap_tzdesc4                    35
     D*                                    text('Location Time Zone')
     D*
